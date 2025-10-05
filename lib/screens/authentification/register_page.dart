import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  final _nameController = TextEditingController();
  final _mailController = TextEditingController();  // ✅ remplacé
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:3000/api/auth/register"), // ⚠️ Android Emulator
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nom": _nameController.text,
        "mail": _mailController.text,  // ✅ remplacé
        "numero_telephone": _phoneController.text,
        "password": _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte créé avec succès ✅")),
      );
      Navigator.pushNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${response.body}")),
      );
    }
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
              const Text("Créer votre compte",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Champs
              TextField(controller: _nameController, decoration: _input("Nom")), // ✅ traduit
              const SizedBox(height: 20),
              TextField(controller: _mailController, decoration: _input("Mail")), // ✅ remplacé
              const SizedBox(height: 20),
              TextField(controller: _phoneController, decoration: _input("Téléphone")), // ✅ traduit
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _input("Mot de passe").copyWith( // ✅ traduit
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

              // Bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("S'inscrire", // ✅ traduit
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/login"),
                  child: const Text.rich(TextSpan(
                      text: "Vous avez déjà un compte ? ", // ✅ traduit
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                            text: "Se connecter",
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
