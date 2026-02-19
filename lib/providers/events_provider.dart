import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // ✅ favoris persistés (IDs)
  static const String _favKey = "favorite_event_ids";
  final Set<int> _favoriteIds = {};

  EventsProvider() {
    _loadFavorites(); // ✅ recharge automatiquement au démarrage
  }

  void setSelectedType(String? type) {
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

  // ✅ Favoris (fusion events + nearby) + sans doublons
  List<Map<String, dynamic>> get favorites {
    final all = <Map<String, dynamic>>[
      ..._events,
      ..._nearbyEvents,
    ];

    final seen = <int>{};
    final result = <Map<String, dynamic>>[];

    for (final e in all) {
      final id = _extractId(e["id"]);
      if (id == null) continue;

      if (_favoriteIds.contains(id) && !seen.contains(id)) {
        seen.add(id);
        e["isFavorite"] = true;
        result.add(e);
      }
    }

    return result;
  }

  // -------------------------
  // Helpers favoris persistés
  // -------------------------
  int? _extractId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return int.tryParse(raw?.toString() ?? "");
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favKey) ?? [];

    _favoriteIds
      ..clear()
      ..addAll(ids.map((s) => int.tryParse(s)).whereType<int>());

    // applique aux listes déjà chargées
    _applyFavoritesToList(_events);
    _applyFavoritesToList(_nearbyEvents);

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favKey,
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }

  void _applyFavoritesToList(List<Map<String, dynamic>> list) {
    for (final ev in list) {
      final id = _extractId(ev["id"]);
      if (id != null) {
        ev["isFavorite"] = _favoriteIds.contains(id);
      } else {
        ev["isFavorite"] = ev["isFavorite"] ?? false;
      }
    }
  }

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

          // ✅ favoris persistés
          final id = _extractId(map["id"]);
          map["isFavorite"] = id != null ? _favoriteIds.contains(id) : false;

          return map;
        }).toList();

        _applyFavoritesToList(_events);
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

  // ----- RÉCUPÉRER LES EVENTS PROCHE D'UN UTILISATEUR (coords stockées en DB) -----
  Future<void> fetchNearbyEvents(String mail) async {
    if (mail.isEmpty) return;

    _isLoadingNearby = true;
    _nearbyError = null;
    notifyListeners();

    try {
      final uri = Uri.parse("$_baseUrl/api/events/nearby/by-user").replace(
        queryParameters: {
          "mail": mail,
          "radiusKm": "25",
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final mapped = data.map((e) {
          final map = Map<String, dynamic>.from(e);

          if (map["image_url"] != null &&
              map["image_url"].toString().isNotEmpty &&
              !map["image_url"].toString().startsWith("http")) {
            map["image_url"] = "$_baseUrl${map["image_url"]}";
          }

          if (map["distance"] != null) {
            final d = map["distance"];
            map["distance"] =
            (d is num) ? d.toDouble() : double.tryParse(d.toString());
          }

          final id = _extractId(map["id"]);
          map["isFavorite"] = id != null ? _favoriteIds.contains(id) : false;

          return map;
        }).toList();

        _nearbyEvents = mapped.where((ev) {
          final d = ev["distance"];
          if (d == null) return false;
          final dist = (d is num) ? d.toDouble() : double.tryParse(d.toString());
          return dist != null && dist <= 25.0;
        }).toList();

        _applyFavoritesToList(_nearbyEvents);
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

  // ✅ NOUVEAU : recalcul nearby à partir de la position actuelle (lat/lng)
  Future<void> fetchNearbyEventsByCoords({
    required double lat,
    required double lng,
    int radiusKm = 25,
  }) async {
    _isLoadingNearby = true;
    _nearbyError = null;
    notifyListeners();

    try {
      final uri = Uri.parse("$_baseUrl/api/events/nearby/by-coords").replace(
        queryParameters: {
          "lat": lat.toString(),
          "lng": lng.toString(),
          "radiusKm": radiusKm.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final mapped = data.map((e) {
          final map = Map<String, dynamic>.from(e);

          if (map["image_url"] != null &&
              map["image_url"].toString().isNotEmpty &&
              !map["image_url"].toString().startsWith("http")) {
            map["image_url"] = "$_baseUrl${map["image_url"]}";
          }

          if (map["distance"] != null) {
            final d = map["distance"];
            map["distance"] = (d is num) ? d.toDouble() : double.tryParse(d.toString());
          }

          final id = _extractId(map["id"]);
          map["isFavorite"] = id != null ? _favoriteIds.contains(id) : false;

          return map;
        }).toList();

        _nearbyEvents = mapped;
        _applyFavoritesToList(_nearbyEvents);
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
    final index = _events.indexWhere((e) => _extractId(e["id"]) == id);
    if (index == -1) return;

    _events[index]["likes"] = (_events[index]["likes"] ?? 0) + 1;
    notifyListeners();
  }

  // Incrémenter un dislike
  void dislikeEvent(int id) {
    final index = _events.indexWhere((e) => _extractId(e["id"]) == id);
    if (index == -1) return;

    _events[index]["dislikes"] = (_events[index]["dislikes"] ?? 0) + 1;
    notifyListeners();
  }

  //  Ajouter / retirer des favoris (persisté + synchro events & nearby)
  void toggleFavorite(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }

    _applyFavoritesToList(_events);
    _applyFavoritesToList(_nearbyEvents);

    _saveFavorites();
    notifyListeners();
  }
}
