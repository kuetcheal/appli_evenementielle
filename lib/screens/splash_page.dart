import 'dart:async';
import 'package:flutter/material.dart';

// ✅ On ouvre la page principale de l’app
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  Timer? _dotTimer;
  Timer? _navigationTimer;

  int _activeDot = 0;
  final int _dotCount = 5;
  final Duration _dotDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    // Animation des points
    _dotTimer = Timer.periodic(_dotDuration, (timer) {
      if (!mounted) return;

      setState(() {
        _activeDot = (_activeDot + 1) % _dotCount;
      });
    });

    // ✅ Après le splash, on va vers l’accueil public
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      _dotTimer?.cancel();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _navigationTimer?.cancel();
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
              Image.asset(
                "assets/logo-event.png",
                height: 120,
              ),

              const SizedBox(height: 50),

              const Text(
                "Welcome to you",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              Image.asset(
                "assets/bienvenu.png",
                height: 250,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_dotCount, (index) {
                  final isActive = index == _activeDot;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFB8860B)
                          : Colors.grey.shade300,
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