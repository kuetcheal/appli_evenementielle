import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get _baseUrl => AppConfig.apiUrl;

  Future<String?> createSubscriptionSession({
    required String planCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.trim().isEmpty) {
        _errorMessage = "Veuillez vous connecter pour choisir un abonnement.";
        return null;
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/api/payments/create-subscription-session"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "planCode": planCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["url"] != null) {
        return data["url"].toString();
      }

      _errorMessage =
          data["error"]?.toString() ?? "Impossible de créer la session Stripe.";
      return null;
    } catch (e) {
      _errorMessage = "Erreur réseau : $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}