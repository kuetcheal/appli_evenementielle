import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notifications_provider.dart';

class NotificationsConsentPage extends StatelessWidget {
  const NotificationsConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.notifications_active, size: 42),
              const SizedBox(height: 18),
              const Text(
                "Reste informé des nouveaux événements",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Active la cloche pour voir immédiatement les nouveaux events ajoutés dans l’application.",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const Spacer(),

              // Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Activer les notifications",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: notif.enabled,
                      onChanged: (v) => notif.setEnabled(v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Boutons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2E44),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Ici tu navigues vers Login/Signup (à adapter)
                    Navigator.pop(context);
                  },
                  child: const Text("Continuer"),
                ),
              ),

              TextButton(
                onPressed: () async {
                  await notif.setEnabled(false);
                  Navigator.pop(context);
                },
                child: const Text("Plus tard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}