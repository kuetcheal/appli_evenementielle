// lib/screens/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // On récupère les champs stockés lors de la connexion
    final adresse = userProvider.user?["Adresse"] ?? "Adresse inconnue";
    final codePostal = userProvider.user?["code_postal"] ?? "";

    return Container(
      height: 210,
      decoration: const BoxDecoration(
        color: Color(0xFF0A2E44),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Column(
        children: [
          // Ligne notif + localisation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.notifications, color: Colors.white),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Votre adresse",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 2),

                  // 🔥 Voici l'adresse réelle de l'utilisateur
                  Text(
                    "$adresse, $codePostal",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),

          const SizedBox(height: 12),

          // Barre de recherche + bouton filtres
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Rechercher...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.filter_list, color: Colors.white),
                label: const Text(
                  "Filtres",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
