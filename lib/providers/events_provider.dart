import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsProvider extends ChangeNotifier {
  static const String _baseUrl = "http://192.168.1.53:3000";

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _nearbyEvents = [];

  bool _isLoading = false;
  bool _isLoadingNearby = false;

  String? _error;
  String? _nearbyError;

  // ----- GETTERS -----
  List<Map<String, dynamic>> get events => _events;
  List<Map<String, dynamic>> get nearbyEvents => _nearbyEvents;

  bool get isLoading => _isLoading;
  bool get isLoadingNearby => _isLoadingNearby;

  String? get error => _error;
  String? get nearbyError => _nearbyError;

  // ✅ Liste filtrée des favoris (pour la page "Mes favoris")
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

  // 👍 Incrémenter un like
  void likeEvent(int id) {
    final index = _events.indexWhere((e) => e["id"] == id);
    if (index == -1) return;

    _events[index]["likes"] = (_events[index]["likes"] ?? 0) + 1;
    notifyListeners();

    // TODO: appel API pour sauvegarder en BDD si tu veux
  }

  // 👎 Incrémenter un dislike
  void dislikeEvent(int id) {
    final index = _events.indexWhere((e) => e["id"] == id);
    if (index == -1) return;

    _events[index]["dislikes"] = (_events[index]["dislikes"] ?? 0) + 1;
    notifyListeners();

    // TODO: appel API pour sauvegarder en BDD si tu veux
  }

  // ❤️ Ajouter / retirer des favoris
  void toggleFavorite(int id) {
    final index = _events.indexWhere((e) => e["id"] == id);
    if (index == -1) return;

    final current = _events[index]["isFavorite"] ?? false;
    _events[index]["isFavorite"] = !current;
    notifyListeners();

    // TODO: appel API pour sauver en BDD si nécessaire
  }
}
