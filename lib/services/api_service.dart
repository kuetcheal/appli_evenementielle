import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000/api"; // ⚠️ 10.0.2.2 si tu testes sur Android Emulator

  // ✅ Register
  Future<bool> register(String nom, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nom": nom,
        "mail": email,
        "numero_telephone": phone,
        "password": password,
      }),
    );

    return response.statusCode == 201;
  }

  // ✅ Login
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data["token"];

      // Sauvegarder le token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      return true;
    } else {
      return false;
    }
  }

  // ✅ Exemple : Get clients protégés
  Future<List<dynamic>> getClients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/clients"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur: ${response.body}");
    }
  }
}
