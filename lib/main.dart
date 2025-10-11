import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/events_provider.dart';
import 'providers/user_provider.dart'; // ✅ gestion utilisateur

// Écrans principaux
import 'screens/main_page.dart';
import 'screens/authentification/login_page.dart';
import 'screens/authentification/register_page.dart';
import 'screens/authentification/forget_password_page.dart';
import 'screens/authentification/verification_page.dart';
import 'screens/evenement/detail_event_page.dart';
import 'screens/splash_page.dart';

// ✅ Nouvelles pages profil
import 'screens/profile/edit_profile_page.dart';
import 'screens/profile/delete_profile_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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

      // Page d’accueil au lancement
      initialRoute: "/splash",

      // ✅ Définition de toutes les routes
      routes: {
        "/splash": (context) => const SplashPage(),
        "/main": (context) => const MainPage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/forget_password": (context) => const ForgetPasswordPage(),
        "/verification": (context) => const VerificationPage(mail: ''),
        "/detail_event": (context) => const DetailEventPage(event: {}),

        // ✅ Ajout des nouvelles pages Profil
        "/edit_profile": (context) => const EditProfilePage(),
        "/delete_profile": (context) => const DeleteProfilePage(),
      },
    );
  }
}
