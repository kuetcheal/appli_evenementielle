import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ContactProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //  URL dynamique depuis .env
  String get _endpoint => "${AppConfig.apiUrl}/api/contact";

  Future<bool> sendContact({
    required String nom,
    required String email,
    required String message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "email": email,
          "message": message,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Par sécurité: parfois ce n'est pas du JSON
        try {
          final data = jsonDecode(response.body);
          _errorMessage = data["message"] ?? data["error"] ?? "Erreur inconnue";
        } catch (_) {
          _errorMessage = "Erreur serveur : ${response.statusCode}";
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Erreur réseau : $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
