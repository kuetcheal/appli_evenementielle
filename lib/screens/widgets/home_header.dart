// lib/screens/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/notifications_provider.dart';

import '../profile/addresses_page.dart';
import 'notifications_page.dart'; // adapte le chemin si ton fichier est ailleurs

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final notifProvider = context.watch<NotificationsProvider>();

    final adresse = userProvider.displayedAddress;
    final codePostal = userProvider.displayedPostalCode;
    final isGps = userProvider.useCurrentLocation;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2E44),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔔 Notifications + badge
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications, color: Colors.white),

                    // Badge rouge si notif activées + nouveaux events
                    if (notifProvider.enabled && notifProvider.badgeCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Text(
                            "${notifProvider.badgeCount}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Adresse (inchangé)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddressesPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Votre adresse",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              if (isGps) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.my_location, size: 14, color: Colors.white70),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            codePostal.trim().isEmpty ? adresse : "$adresse, $codePostal",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}