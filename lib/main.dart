import 'package:flutter/material.dart';
import 'screens/main_page.dart';
import 'screens/authentification/login_page.dart';
import 'screens/authentification/register_page.dart';
import 'screens/authentification/forget_password_page.dart';
import 'screens/authentification/verification_page.dart'; // ✅ import ajouté
import 'screens/evenement/detail_event_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Voyage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: "/main",
      routes: {
        "/main": (context) => const MainPage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/forget_password": (context) => const ForgetPasswordPage(),
        "/verification": (context) => const VerificationPage(
          mail: '',
        ),
        "/detail_event": (context) => const DetailEventPage(
          event: {}, // ⚠️ mettre un Map par défaut
        ),
      },
    );
  }
}
