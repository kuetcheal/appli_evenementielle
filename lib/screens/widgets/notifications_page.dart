import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notifications_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Quand on arrive, on marque comme vu (tu peux aussi le faire après scroll)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notif = context.read<NotificationsProvider>();
      await notif.markAllAsSeen();
      // Optionnel: après markAll, tu peux refresh pour afficher “0”
      // await notif.refreshNewEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF0A2E44),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toggle
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
                      "Activer la cloche",
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

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: notif.enabled ? () => notif.refreshNewEvents() : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Actualiser"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (!notif.enabled)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text(
                  "Les notifications sont désactivées. Active la cloche pour voir les nouveaux events.",
                  style: TextStyle(color: Colors.black54),
                ),
              ),

            if (notif.enabled) ...[
              if (notif.loading) const LinearProgressIndicator(),
              if (notif.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(notif.error!, style: const TextStyle(color: Colors.red)),
                ),

              const SizedBox(height: 10),

              Expanded(
                child: notif.newEvents.isEmpty
                    ? const Center(
                  child: Text("Aucun nouvel événement pour le moment."),
                )
                    : ListView.separated(
                  itemCount: notif.newEvents.length,
                  separatorBuilder: (_, __) => const Divider(height: 18),
                  itemBuilder: (context, i) {
                    final ev = notif.newEvents[i];
                    final title = (ev["title"] ?? "").toString();
                    final city = (ev["city"] ?? "").toString();
                    final date = (ev["date_event"] ?? "").toString();

                    return ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text("$date • $city"),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}