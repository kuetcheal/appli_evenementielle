import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final _mailController = TextEditingController(); // renamed for clarity
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final mail = _mailController.text.trim();
    final password = _passwordController.text;

    if (mail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mail": mail, // important -> mail (pas email)
          "password": password,
        }),
      );

      // Debug: affiche status et body
      debugPrint("Login status: ${response.statusCode}");
      debugPrint("Login body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data["token"] as String?;

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Réponse inattendue: ${response.body}")),
          );
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);

          // Optionnel: sauvegarder user info si utile
          // await prefs.setString("user", jsonEncode(data['user']));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // affiche message d'erreur renvoyé par l'API (body)
        String message = response.body;
        try {
          final parsed = jsonDecode(response.body);
          if (parsed is Map && parsed['message'] != null) {
            message = parsed['message'].toString();
          } else if (parsed is Map && parsed['error'] != null) {
            message = parsed['error'].toString();
          }
        } catch (_) { /* ignore JSON parse errors */ }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $message")),
        );
      }
    } catch (e) {
      debugPrint("Login request failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset("assets/logo-event.png", height: 100)),
              const SizedBox(height: 20),
              const Text("Welcome Back 👋",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Sign in to start managing your projects.",
                  style: TextStyle(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 30),

              // Champs
              TextField(
                controller: _mailController,
                decoration: _input("Mail"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _input("Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: _loading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Connectez-vous",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/register"),
                  child: const Text.rich(TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold))
                      ])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
    );
  }
}
