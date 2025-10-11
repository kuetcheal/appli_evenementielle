import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user["nom"] ?? "";
      _mailController.text = user["mail"] ?? "";
      _phoneController.text = user["numero_telephone"] ?? "";
    }
  }

  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    final id = user["id"];
    final url = Uri.parse("http://10.0.2.2:3000/api/auth/update/$id");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": _nameController.text.trim(),
          "mail": _mailController.text.trim(),
          "numero_telephone": _phoneController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body);
        userProvider.setUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil mis à jour avec succès ✅")),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur: ${response.body}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur réseau : $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  } // 👈 ici on ferme bien la fonction _updateProfile()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier mon profil"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: _input("Nom complet"),
                validator: (v) =>
                v!.isEmpty ? "Veuillez entrer votre nom complet" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _mailController,
                decoration: _input("Email"),
                validator: (v) =>
                v!.isEmpty ? "Veuillez entrer votre email" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: _input("Numéro de téléphone"),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "ENREGISTRER",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/delete_profile"),
                child: const Text(
                  "Supprimer mon compte",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } // 👈 ici on ferme bien le widget build()

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
    );
  }
} // 👈 fermeture finale de la classe
