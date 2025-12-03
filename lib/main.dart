import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/events_provider.dart';
import 'providers/user_provider.dart';
import 'providers/contact_provider.dart';

// Écrans principaux
import 'screens/main_page.dart';
import 'screens/authentification/login_page.dart';
import 'screens/authentification/register_page.dart';
import 'screens/authentification/forget_password_page.dart';
import 'screens/authentification/verification_page.dart';
import 'screens/evenement/detail_event_page.dart';
import 'screens/splash_page.dart';

// page de paiement
import 'screens/paiement/paiement_page.dart';
import 'screens/paiement/ticket_webview_page.dart';


// ✅ Pages Profil
import 'screens/profile/edit_profile_page.dart';
import 'screens/profile/delete_profile_page.dart';
import 'screens/profile/partenaire_page.dart';
import 'screens/profile/parametre_page.dart';
import 'screens/profile/service_page.dart';
import 'screens/profile/contact_page.dart';
import 'screens/profile/favoris_page.dart';
import 'screens/profile/aide_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
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

      // ✅ Page d’accueil au lancement
      initialRoute: "/splash",

      // ✅ Définition de toutes les routes
      routes: {
        // --- Authentification ---
        "/splash": (context) => const SplashPage(),
        "/main": (context) => const MainPage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/forget_password": (context) => const ForgetPasswordPage(),
        "/verification": (context) => const VerificationPage(mail: ''),

        // --- Événements ---
        "/detail_event": (context) => const DetailEventPage(event: {}),

        // --- paiement ---
        "/paiement": (context) => const PaiementPage(),
        "/ticket_webview": (context) => const TicketWebViewPage(url: ""),


        // --- Profil ---
        "/edit_profile": (context) => const EditProfilePage(),
        "/delete_profile": (context) => const DeleteProfilePage(),
        "/partenaire": (context) => const PartenairePage(),
        "/parametres": (context) => const ParametrePage(),
        "/services": (context) => const ServicePage(),
        "/contact": (context) => const ContactPage(),
        "/favoris": (context) => const FavorisPage(),
        "/aide": (context) => const AidePage(),
      },
    );
  }
}
