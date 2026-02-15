import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class SavedAddress {
  final String address;
  final String postalCode;
  final String city;

  SavedAddress({
    required this.address,
    required this.postalCode,
    required this.city,
  });

  Map<String, dynamic> toJson() => {
    "address": address,
    "postalCode": postalCode,
    "city": city,
  };

  static SavedAddress fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      address: (json["address"] ?? "").toString(),
      postalCode: (json["postalCode"] ?? "").toString(),
      city: (json["city"] ?? "").toString(),
    );
  }
}

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  // ✅ URL dynamique depuis .env
  String get _baseUrl => "${AppConfig.apiUrl}/api/auth";

  // ----------------------------
  // ✅ Historique d'adresses
  // ----------------------------
  static const String _historyKey = "address_history";
  final List<SavedAddress> _addressHistory = [];
  List<SavedAddress> get addressHistory => List.unmodifiable(_addressHistory);

  UserProvider() {
    _loadAddressHistory();
  }

  Future<void> _loadAddressHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);

    if (raw == null || raw.trim().isEmpty) return;

    try {
      final List<dynamic> data = jsonDecode(raw);
      _addressHistory
        ..clear()
        ..addAll(
          data.map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e))),
        );
      notifyListeners();
    } catch (_) {
      // ignore parsing errors
    }
  }

  Future<void> _saveAddressHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_addressHistory.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, raw);
  }

  int _findAddressIndex(SavedAddress a) {
    return _addressHistory.indexWhere((x) =>
    x.address == a.address &&
        x.postalCode == a.postalCode &&
        x.city == a.city);
  }

  // ✅ Met à jour l’adresse courante + ajoute à l’historique (persisté)
  Future<void> setCurrentAddress({
    required String address,
    required String postalCode,
    required String city,
  }) async {
    _user ??= {};

    // ⚠️ Tes clés actuelles : "Adresse" et "code_postal"
    _user!["Adresse"] = address;
    _user!["code_postal"] = postalCode;
    _user!["city"] = city;

    final item = SavedAddress(address: address, postalCode: postalCode, city: city);

    // ✅ sans doublon : on retire puis on remet en haut
    final idx = _findAddressIndex(item);
    if (idx != -1) _addressHistory.removeAt(idx);

    _addressHistory.insert(0, item);

    // limite à 10
    if (_addressHistory.length > 10) _addressHistory.removeLast();

    await _saveAddressHistory();
    notifyListeners();
  }

  // ✅ Placeholder (tu brancheras Geolocator + reverse geocoding plus tard)
  Future<void> useCurrentLocationAsAddress() async {
    // TODO: récupérer latitude/longitude, puis reverse geocode -> address/postalCode/city
    await setCurrentAddress(
      address: "Position actuelle",
      postalCode: "",
      city: "Autour de moi",
    );
  }

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
          _errorMessage =
              decoded['error'] ?? decoded['message'] ?? 'Erreur inconnue';
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

        // ✅ Optionnel : si le backend renvoie Adresse/code_postal/city, on les ajoute à l’historique
        final a = _user?["Adresse"]?.toString() ?? "";
        final cp = _user?["code_postal"]?.toString() ?? "";
        final city = _user?["city"]?.toString() ?? "";

        if (a.trim().isNotEmpty) {
          await setCurrentAddress(address: a, postalCode: cp, city: city);
        } else {
          notifyListeners();
        }

        return true;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          _errorMessage = decoded['error'] ??
              decoded['message'] ??
              "Erreur d'identifiants";
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
          _errorMessage =
              decoded['error'] ?? decoded['message'] ?? "Code invalide";
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
          _errorMessage = decoded['error'] ??
              decoded['message'] ??
              "Impossible d’envoyer l’e-mail.";
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
