import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class AddressEntry {
  final String address;
  final String postalCode;
  final String city;
  final double? latitude;
  final double? longitude;

  const AddressEntry({
    required this.address,
    required this.postalCode,
    required this.city,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    "address": address,
    "postalCode": postalCode,
    "city": city,
    "latitude": latitude,
    "longitude": longitude,
  };

  static AddressEntry fromJson(Map<String, dynamic> j) => AddressEntry(
    address: (j["address"] ?? "").toString(),
    postalCode: (j["postalCode"] ?? "").toString(),
    city: (j["city"] ?? "").toString(),
    latitude: (j["latitude"] is num) ? (j["latitude"] as num).toDouble() : double.tryParse("${j["latitude"]}"),
    longitude: (j["longitude"] is num) ? (j["longitude"] as num).toDouble() : double.tryParse("${j["longitude"]}"),
  );
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

  // -------------------------
  // ✅ Adresse affichée (celle sélectionnée)
  // -------------------------
  static const _kDisplayedAddress = "displayed_address";
  static const _kDisplayedPostal = "displayed_postal";
  static const _kDisplayedCity = "displayed_city";
  static const _kUseCurrentLocation = "use_current_location";
  static const _kDisplayedLat = "displayed_lat";
  static const _kDisplayedLng = "displayed_lng";
  static const _kHistory = "address_history_v1";

  String _displayedAddress = "";
  String _displayedPostalCode = "";
  String _displayedCity = "";
  bool _useCurrentLocation = false;
  double? _displayedLat;
  double? _displayedLng;

  List<AddressEntry> _addressHistory = [];
  List<AddressEntry> get addressHistory => List.unmodifiable(_addressHistory);

  // ✅ getters demandés par home_header.dart
  String get displayedAddress {
    if (_displayedAddress.trim().isNotEmpty) return _displayedAddress;
    return (_user?["Adresse"] ?? "Adresse inconnue").toString();
  }

  String get displayedPostalCode {
    if (_displayedPostalCode.trim().isNotEmpty) return _displayedPostalCode;
    return (_user?["code_postal"] ?? "").toString();
  }

  String get displayedCity {
    if (_displayedCity.trim().isNotEmpty) return _displayedCity;
    return (_user?["city"] ?? "").toString();
  }

  bool get useCurrentLocation => _useCurrentLocation;

  double? get displayedLatitude => _displayedLat ?? _toDouble(_user?["latitude"]);
  double? get displayedLongitude => _displayedLng ?? _toDouble(_user?["longitude"]);

  double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  UserProvider() {
    _loadDisplayedAddress();
    _loadHistory();
  }

  // --- MÉTHODE AJOUTÉE ---
  void setUser(Map<String, dynamic> updatedUser) {
    _user = updatedUser;

    // ✅ si aucune adresse affichée sauvegardée, on initialise avec celle du profil
    if (_displayedAddress.trim().isEmpty) {
      _displayedAddress = (_user?["Adresse"] ?? "").toString();
      _displayedPostalCode = (_user?["code_postal"] ?? "").toString();
      _displayedCity = (_user?["city"] ?? "").toString();
      _displayedLat = _toDouble(_user?["latitude"]);
      _displayedLng = _toDouble(_user?["longitude"]);
      _useCurrentLocation = false;
      _saveDisplayedAddress();
    }

    notifyListeners();
  }

  Future<void> _loadDisplayedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    _displayedAddress = prefs.getString(_kDisplayedAddress) ?? "";
    _displayedPostalCode = prefs.getString(_kDisplayedPostal) ?? "";
    _displayedCity = prefs.getString(_kDisplayedCity) ?? "";
    _useCurrentLocation = prefs.getBool(_kUseCurrentLocation) ?? false;
    _displayedLat = prefs.getDouble(_kDisplayedLat);
    _displayedLng = prefs.getDouble(_kDisplayedLng);
    notifyListeners();
  }

  Future<void> _saveDisplayedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayedAddress, _displayedAddress);
    await prefs.setString(_kDisplayedPostal, _displayedPostalCode);
    await prefs.setString(_kDisplayedCity, _displayedCity);
    await prefs.setBool(_kUseCurrentLocation, _useCurrentLocation);

    if (_displayedLat != null) {
      await prefs.setDouble(_kDisplayedLat, _displayedLat!);
    } else {
      await prefs.remove(_kDisplayedLat);
    }

    if (_displayedLng != null) {
      await prefs.setDouble(_kDisplayedLng, _displayedLng!);
    } else {
      await prefs.remove(_kDisplayedLng);
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistory);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _addressHistory = list
          .whereType<Map<String, dynamic>>()
          .map((j) => AddressEntry.fromJson(j))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_addressHistory.map((e) => e.toJson()).toList());
    await prefs.setString(_kHistory, raw);
  }

  void _pushHistory(AddressEntry entry) {
    // évite doublons
    _addressHistory.removeWhere((e) =>
    e.address == entry.address &&
        e.postalCode == entry.postalCode &&
        e.city == entry.city);

    _addressHistory.insert(0, entry);
    if (_addressHistory.length > 15) {
      _addressHistory = _addressHistory.take(15).toList();
    }
    _saveHistory();
  }

  /// ✅ Sélection d’une adresse (manuelle/historique)
  Future<void> setCurrentAddress({
    required String address,
    required String postalCode,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    _displayedAddress = address;
    _displayedPostalCode = postalCode;
    _displayedCity = city;
    _displayedLat = latitude;
    _displayedLng = longitude;
    _useCurrentLocation = false;

    _pushHistory(AddressEntry(
      address: address,
      postalCode: postalCode,
      city: city,
      latitude: latitude,
      longitude: longitude,
    ));

    await _saveDisplayedAddress();
    notifyListeners();
  }

  /// ✅ Position GPS choisie
  Future<void> useCurrentLocationAsAddress({
    required String labelAddress, // ✅ IMPORTANT : correspond à ton AddressesPage
    required String postalCode,
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    _displayedAddress = labelAddress;
    _displayedPostalCode = postalCode;
    _displayedCity = city;
    _displayedLat = latitude;
    _displayedLng = longitude;
    _useCurrentLocation = true;

    _pushHistory(AddressEntry(
      address: labelAddress,
      postalCode: postalCode,
      city: city,
      latitude: latitude,
      longitude: longitude,
    ));

    await _saveDisplayedAddress();
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

        // ✅ sync user -> affichage si vide
        if (_user != null) setUser(_user!);

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
