import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class EventsProvider extends ChangeNotifier {
  // base url depuis .env
  final String _baseUrl = AppConfig.apiUrl;

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _nearbyEvents = [];

  bool _isLoading = false;
  bool _isLoadingNearby = false;

  String? _error;
  String? _nearbyError;

  // ✅ filtre sélectionné (null = tous)
  String? _selectedType;
  String? get selectedType => _selectedType;

  void setSelectedType(String? type) {
    // toggle : si on reclique la même catégorie -> on reset
    if (_selectedType == type) {
      _selectedType = null;
    } else {
      _selectedType = type;
    }
    notifyListeners();
  }

  // ✅ liste filtrée selon event_type (minuscule)
  List<Map<String, dynamic>> get filteredEvents {
    if (_selectedType == null) return _events;

    final wanted = _selectedType!.toLowerCase().trim();
    return _events.where((e) {
      final t = (e["event_type"] ?? "").toString().toLowerCase().trim();
      return t == wanted;
    }).toList();
  }

  // ----- GETTERS -----
  List<Map<String, dynamic>> get events => _events;
  List<Map<String, dynamic>> get nearbyEvents => _nearbyEvents;

  bool get isLoading => _isLoading;
  bool get isLoadingNearby => _isLoadingNearby;

  String? get error => _error;
  String? get nearbyError => _nearbyError;

  // Liste filtrée des favoris (pour la page "Mes favoris")
  List<Map<String, dynamic>> get favorites =>
      _events.where((e) => (e["isFavorite"] ?? false) == true).toList();

  // ----- RÉCUPÉRER TOUS LES EVENTS -----
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("$_baseUrl/api/events"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _events = data.map((e) {
          final map = Map<String, dynamic>.from(e);

          // image_url relative -> absolue
          if (map["image_url"] != null &&
              map["image_url"].toString().isNotEmpty &&
              !map["image_url"].toString().startsWith("http")) {
            map["image_url"] = "$_baseUrl${map["image_url"]}";
          }

          // ✅ Normalisation event_type (minuscule) + gestion null
          if (map["event_type"] == null ||
              map["event_type"].toString().trim().isEmpty ||
              map["event_type"].toString().toLowerCase() == "null") {
            map["event_type"] = "autre";
          } else {
            map["event_type"] =
                map["event_type"].toString().toLowerCase().trim();
          }

          // Champs locaux pour le front
          map["likes"] = map["likes"] ?? 0;
          map["dislikes"] = map["dislikes"] ?? 0;
          map["isFavorite"] = map["isFavorite"] ?? false;

          return map;
        }).toList();
      } else {
        _error = "Erreur serveur : ${response.statusCode}";
      }
    } catch (e) {
      _error = "Erreur de connexion : $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ----- RÉCUPÉRER LES EVENTS PROCHE D'UN UTILISATEUR -----
  Future<void> fetchNearbyEvents(String mail) async {
    if (mail.isEmpty) return;

    _isLoadingNearby = true;
    _nearbyError = null;
    notifyListeners();

    try {
      final uri = Uri.parse("$_baseUrl/api/events/nearby/by-user")
          .replace(queryParameters: {"mail": mail});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _nearbyEvents = data.map((e) {
          final map = Map<String, dynamic>.from(e);

          // image_url relative -> absolue
          if (map["image_url"] != null &&
              map["image_url"].toString().isNotEmpty &&
              !map["image_url"].toString().startsWith("http")) {
            map["image_url"] = "$_baseUrl${map["image_url"]}";
          }

          // distance renvoyée par l'API (en km)
          if (map["distance"] != null) {
            map["distance"] = (map["distance"] as num).toDouble();
          }

          // ✅ Normalisation event_type aussi ici (si tu filtres nearby un jour)
          if (map["event_type"] == null ||
              map["event_type"].toString().trim().isEmpty ||
              map["event_type"].toString().toLowerCase() == "null") {
            map["event_type"] = "autre";
          } else {
            map["event_type"] =
                map["event_type"].toString().toLowerCase().trim();
          }

          return map;
        }).toList();
      } else {
        _nearbyError = "Erreur serveur : ${response.statusCode}";
      }
    } catch (e) {
      _nearbyError = "Erreur de connexion : $e";
    } finally {
      _isLoadingNearby = false;
      notifyListeners();
    }
  }

  // Incrémenter un like
  void likeEvent(int id) {
    final index = _events.indexWhere((e) => e["id"] == id);
    if (index == -1) return;

    _events[index]["likes"] = (_events[index]["likes"] ?? 0) + 1;
    notifyListeners();
  }

  // Incrémenter un dislike
  void dislikeEvent(int id) {
    final index = _events.indexWhere((e) => e["id"] == id);
    if (index == -1) return;

    _events[index]["dislikes"] = (_events[index]["dislikes"] ?? 0) + 1;
    notifyListeners();
  }

  // Ajouter / retirer des favoris
  void toggleFavorite(int id) {
    final index = _events.indexWhere((e) => e["id"] == id);
    if (index == -1) return;

    final current = _events[index]["isFavorite"] ?? false;
    _events[index]["isFavorite"] = !current;
    notifyListeners();
  }
}
