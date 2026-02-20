import 'package:flutter/material.dart';

class TransportModeSheet {
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _TransportModeContent(),
    );
  }
}

class _TransportModeContent extends StatelessWidget {
  const _TransportModeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choisir un mode de transport",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            const SizedBox(height: 14),

            _tile(
              context,
              icon: Icons.directions_car,
              title: "Voiture",
              subtitle: "Trajet en voiture",
              value: "driving",
            ),
            _tile(
              context,
              icon: Icons.directions_walk,
              title: "Marche",
              subtitle: "Trajet à pied",
              value: "walking",
            ),
            _tile(
              context,
              icon: Icons.directions_bike,
              title: "Vélo",
              subtitle: "Trajet à vélo",
              value: "bicycling",
            ),
            _tile(
              context,
              icon: Icons.directions_transit,
              title: "Transport",
              subtitle: "Bus / métro / train",
              value: "transit",
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String value,
      }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF6C63FF)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      onTap: () => Navigator.pop(context, value),
    );
  }
}