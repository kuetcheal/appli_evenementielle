// lib/screens/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../profile/addresses_page.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

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
              const Icon(Icons.notifications, color: Colors.white),

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
