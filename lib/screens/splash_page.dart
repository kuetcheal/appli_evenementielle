import 'dart:async';
import 'package:flutter/material.dart';
import 'authentification/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Après 10 secondes, redirige vers la page Login
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animé
            RotationTransition(
              turns: _animation,
              child: Image.asset(
                "assets/logo-event.png", // ton logo
                height: 100,
              ),
            ),
            const SizedBox(height: 20),

            // Texte de bienvenue
            const Text(
              "Welcome to you",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            // Image ajoutée
            Image.asset(
              "assets/bienvenu.png", // place ton image ici
              height: 180,
            ),

            const SizedBox(height: 40),

            // Indicateur de chargement
            const CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
