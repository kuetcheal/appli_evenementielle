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

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ⚡ Utiliser l'adresse IP locale de ton PC
      final response = await http.get(
        Uri.parse("http://192.168.1.53:3000/api/events"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // On corrige les URLs d'images pour qu’elles soient accessibles depuis le téléphone
        _events = data.map((e) {
          final map = Map<String, dynamic>.from(e);

          if (map["image_url"] != null && map["image_url"].toString().isNotEmpty) {
            map["image_url"] = "http://192.168.1.53:3000${map["image_url"]}";
          }

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
}
