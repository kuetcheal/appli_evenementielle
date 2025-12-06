import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/user_provider.dart';

class NearbySection extends StatefulWidget {
  const NearbySection({Key? key}) : super(key: key);

  @override
  State<NearbySection> createState() => _NearbySectionState();
}

class _NearbySectionState extends State<NearbySection> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

      final mail = userProvider.user?["mail"]?.toString() ?? "";

      if (mail.isNotEmpty) {
        eventsProvider.fetchNearbyEvents(mail);
      }

      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, EventsProvider>(
      builder: (context, userProvider, eventsProvider, child) {
        final mail = userProvider.user?["mail"]?.toString() ?? "";

        if (mail.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Connectez-vous pour voir les événements près de chez vous.",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        if (eventsProvider.isLoadingNearby) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (eventsProvider.nearbyError != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              eventsProvider.nearbyError!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final events = eventsProvider.nearbyEvents;

        if (events.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Aucun événement proche pour le moment.",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "À proximité de vous",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // --- ListView des events proches ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final e = events[index];

                final title = e["title"] ?? "Événement";
                final location = e["location"] ?? "";
                final city = e["city"] ?? "";
                final distance = e["distance"]?.toDouble();
                final img = e["image_url"];

                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: ouvrir page détail
                    },
                    child: Row(
                      children: [
                        // 🖼 Image
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                          child: img != null
                              ? Image.network(
                            img,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.event),
                          ),
                        ),

                        // Infos event
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$location, $city",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                if (distance != null)
                                  Text(
                                    "${distance.toStringAsFixed(1)} km de vous",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
