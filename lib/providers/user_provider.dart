import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  static const String baseUrl = "http://192.168.1.53:3000/api/auth";

  // ✅ --- MÉTHODE AJOUTÉE ---
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "mail": mail,
          "numero_telephone": numeroTelephone,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // ✅ OK
      } else {
        final decoded = jsonDecode(response.body);
        _errorMessage = decoded['error'] ?? 'Erreur inconnue';
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
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mail": mail, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data["token"];
        _user = data["user"];

        // ✅ Enregistre le token localement
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        return true;
      } else {
        final decoded = jsonDecode(response.body);
        _errorMessage = decoded['error'] ?? "Erreur d'identifiants";
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

  // ---- VÉRIFICATION EMAIL (Code à 6 chiffres) ----
  Future<bool> verifyEmail({
    required String mail,
    required String code,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mail": mail, "code": code}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        _errorMessage = decoded['error'] ?? "Code invalide";
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
