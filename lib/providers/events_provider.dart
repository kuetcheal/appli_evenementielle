import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class EventsProvider extends ChangeNotifier {
  final String _baseUrl = AppConfig.apiUrl;

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _nearbyEvents = [];
  List<Map<String, dynamic>> _popularEvents = [];

  bool _isLoading = false;
  bool _isLoadingNearby = false;
  bool _isLoadingPopular = false;

  String? _error;
  String? _nearbyError;
  String? _popularError;

  String? _selectedType;
  String? get selectedType => _selectedType;

  static const String _favKey = "favorite_event_ids";
  final Set<int> _favoriteIds = {};

  EventsProvider() {
    _loadFavorites();
  }

  List<Map<String, dynamic>> get events => _events;
  List<Map<String, dynamic>> get nearbyEvents => _nearbyEvents;
  List<Map<String, dynamic>> get popularEvents => _popularEvents;

  bool get isLoading => _isLoading;
  bool get isLoadingNearby => _isLoadingNearby;
  bool get isLoadingPopular => _isLoadingPopular;

  String? get error => _error;
  String? get nearbyError => _nearbyError;
  String? get popularError => _popularError;

  void setSelectedType(String? type) {
    if (_selectedType == type) {
      _selectedType = null;
    } else {
      _selectedType = type;
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredEvents {
    if (_selectedType == null) return _events;

    final wanted = _selectedType!.toLowerCase().trim();

    return _events.where((e) {
      final t = (e["event_type"] ?? "").toString().toLowerCase().trim();
      return t == wanted;
    }).toList();
  }

  List<Map<String, dynamic>> get favorites {
    final all = <Map<String, dynamic>>[
      ..._events,
      ..._nearbyEvents,
      ..._popularEvents,
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

  int? _extractId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return int.tryParse(raw?.toString() ?? "");
  }

  double? _toDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return double.tryParse(raw?.toString() ?? "");
  }

  bool _toBool(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw == 1;
    if (raw is String) {
      final v = raw.trim().toLowerCase();
      return v == "1" || v == "true" || v == "yes" || v == "oui";
    }
    return false;
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final headers = {
      "Content-Type": "application/json",
    };

    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  void _normalizeImageUrl(Map<String, dynamic> map) {
    if (map["image_url"] != null &&
        map["image_url"].toString().trim().isNotEmpty &&
        !map["image_url"].toString().startsWith("http")) {
      map["image_url"] = "$_baseUrl${map["image_url"]}";
    }
  }

  void _normalizeEventType(Map<String, dynamic> map) {
    if (map["event_type"] == null ||
        map["event_type"].toString().trim().isEmpty ||
        map["event_type"].toString().toLowerCase() == "null") {
      map["event_type"] = "autre";
    } else {
      map["event_type"] = map["event_type"].toString().toLowerCase().trim();
    }
  }

  Map<String, dynamic> _mapEvent(dynamic e) {
    final map = Map<String, dynamic>.from(e);

    _normalizeImageUrl(map);
    _normalizeEventType(map);

    map["likes"] = map["likes"] ?? 0;
    map["dislikes"] = map["dislikes"] ?? 0;

    map["is_popular"] = _toBool(map["is_popular"]);

    if (map["distance"] != null) {
      map["distance"] = _toDouble(map["distance"]);
    }

    final id = _extractId(map["id"]);
    map["isFavorite"] = id != null ? _favoriteIds.contains(id) : false;

    return map;
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favKey) ?? [];

    _favoriteIds
      ..clear()
      ..addAll(ids.map((s) => int.tryParse(s)).whereType<int>());

    _applyFavoritesToList(_events);
    _applyFavoritesToList(_nearbyEvents);
    _applyFavoritesToList(_popularEvents);

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

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/api/events"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _events = data.map((e) => _mapEvent(e)).toList();
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

  Future<void> fetchPopularEvents() async {
    _isLoadingPopular = true;
    _popularError = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/api/events/popular"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _popularEvents = data.map((e) => _mapEvent(e)).toList();
        _applyFavoritesToList(_popularEvents);
      } else {
        _popularError = "Erreur serveur : ${response.statusCode}";
      }
    } catch (e) {
      _popularError = "Erreur de connexion : $e";
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

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

        _nearbyEvents = data.map((e) => _mapEvent(e)).where((ev) {
          final distance = _toDouble(ev["distance"]);
          return distance != null && distance <= radiusKm;
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

  Future<void> fetchNearbyEvents(String mail) async {
    if (mail.trim().isEmpty) return;

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

      final headers = await _authHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _nearbyEvents = data.map((e) => _mapEvent(e)).where((ev) {
          final distance = _toDouble(ev["distance"]);
          return distance != null && distance <= 25.0;
        }).toList();

        _applyFavoritesToList(_nearbyEvents);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _nearbyError = "Connectez-vous pour utiliser la recherche par profil.";
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

  void likeEvent(int id) {
    final index = _events.indexWhere((e) => _extractId(e["id"]) == id);

    if (index == -1) return;

    _events[index]["likes"] = (_events[index]["likes"] ?? 0) + 1;
    notifyListeners();
  }

  void dislikeEvent(int id) {
    final index = _events.indexWhere((e) => _extractId(e["id"]) == id);

    if (index == -1) return;

    _events[index]["dislikes"] = (_events[index]["dislikes"] ?? 0) + 1;
    notifyListeners();
  }

  void toggleFavorite(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }

    _applyFavoritesToList(_events);
    _applyFavoritesToList(_nearbyEvents);
    _applyFavoritesToList(_popularEvents);

    _saveFavorites();
    notifyListeners();
  }
}