import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'verification_page.dart'; // ✅ import pour la redirection

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  final _nameController = TextEditingController();
  final _mailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // ✅ indicateur de chargement

  Future<void> _register() async {
    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse("http://10.0.2.2:3000/api/auth/register"), // ⚠️ Android Emulator
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nom": _nameController.text.trim(),
        "mail": _mailController.text.trim(),
        "numero_telephone": _phoneController.text.trim(),
        "password": _passwordController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // ✅ Message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Code de vérification envoyé à votre adresse e-mail 📩"),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Redirection vers la page de vérification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationPage(
            mail: _mailController.text.trim(),
          ),
        ),
      );
    } else {
      String errorMsg = "Erreur inconnue";
      try {
        final body = jsonDecode(response.body);
        errorMsg = body['error'] ?? response.body;
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $errorMsg"),
          backgroundColor: Colors.redAccent,
        ),
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
              const Text(
                "Créer votre compte",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Champs du formulaire
              TextField(
                controller: _nameController,
                decoration: _input("Nom"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _mailController,
                decoration: _input("E-mail"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: _input("Téléphone"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _input("Mot de passe").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Bouton S'inscrire
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "S'inscrire",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/login"),
                  child: const Text.rich(
                    TextSpan(
                      text: "Vous avez déjà un compte ? ",
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: "Se connecter",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
    );
  }
}
