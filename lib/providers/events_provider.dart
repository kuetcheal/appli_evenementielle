import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Liste filtrée des favoris (pour la page "Mes favoris")
  List<Map<String, dynamic>> get favorites =>
      _events.where((e) => (e["isFavorite"] ?? false) == true).toList();

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
      await http.get(Uri.parse("http://192.168.1.53:3000/api/events"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _events = data.map((e) {
          final map = Map<String, dynamic>.from(e);

          if (map["image_url"] != null &&
              map["image_url"].toString().isNotEmpty) {
            map["image_url"] = "http://192.168.1.53:3000${map["image_url"]}";
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
