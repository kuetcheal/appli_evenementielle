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
  late Timer _timer;
  int _activeDot = 0; // index du point actif
  final int _dotCount = 5; // nombre de points
  final Duration _dotDuration = const Duration(milliseconds: 500); // vitesse animation

  @override
  void initState() {
    super.initState();

    // Animation des points
    _timer = Timer.periodic(_dotDuration, (timer) {
      setState(() {
        _activeDot = (_activeDot + 1) % _dotCount;
      });
    });

    // Après 10 secondes, redirige vers la page Login
    Timer(const Duration(seconds: 10), () {
      _timer.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Logo (fixe maintenant) ---
              Image.asset(
                "assets/logo-event.png",
                height: 120,
              ),

              const SizedBox(height: 50),

              // --- Texte d’accueil ---
              const Text(
                "Welcome to you",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              // --- Image d’illustration ---
              Image.asset(
                "assets/bienvenu.png",
                height: 250,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 60),

              // --- Animation en pointillés ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_dotCount, (index) {
                  bool isActive = index == _activeDot;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFB8860B) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
