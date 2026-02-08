import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  // ✅ URL dynamique depuis .env
  String get _baseUrl => "${AppConfig.apiUrl}/api/auth";

  // --- MÉTHODE AJOUTÉE ---
  void setUser(Map<String, dynamic> updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // ---- INSCRIPTION ----
  Future<bool> register({
    required String nom,
    required String mail,
    required String numeroTelephone,
    required String password,
    required String adresse,
    required String codePostal,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "mail": mail,
          "numero_telephone": numeroTelephone,
          "password": password,
          "Adresse": adresse,
          "code_postal": codePostal,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          _errorMessage = decoded['error'] ?? decoded['message'] ?? 'Erreur inconnue';
        } catch (_) {
          _errorMessage = "Erreur serveur : ${response.statusCode}";
        }
        return false;
      }
    } catch (e) {
      _errorMessage = "Erreur réseau : $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- CONNEXION ----
  Future<bool> login({
    required String mail,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mail": mail, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data["token"];
        _user = (data["user"] is Map<String, dynamic>)
            ? Map<String, dynamic>.from(data["user"])
            : null;

        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString("token", token.toString());
        }

        return true;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          _errorMessage = decoded['error'] ?? decoded['message'] ?? "Erreur d'identifiants";
        } catch (_) {
          _errorMessage = "Erreur serveur : ${response.statusCode}";
        }
        return false;
      }
    } catch (e) {
      _errorMessage = "Erreur réseau : $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- VÉRIFICATION EMAIL ----
  Future<bool> verifyEmail({
    required String mail,
    required String code,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mail": mail, "code": code}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          _errorMessage = decoded['error'] ?? decoded['message'] ?? "Code invalide";
        } catch (_) {
          _errorMessage = "Erreur serveur : ${response.statusCode}";
        }
        return false;
      }
    } catch (e) {
      _errorMessage = "Erreur réseau : $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- MOT DE PASSE OUBLIÉ ----
  Future<bool> forgotPassword({required String mail}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mail": mail}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          _errorMessage = decoded['error'] ?? decoded['message'] ?? "Impossible d’envoyer l’e-mail.";
        } catch (_) {
          _errorMessage = "Erreur serveur : ${response.statusCode}";
        }
        return false;
      }
    } catch (e) {
      _errorMessage = "Erreur réseau : $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- DÉCONNEXION ----
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    _user = null;
    notifyListeners();
  }
}
