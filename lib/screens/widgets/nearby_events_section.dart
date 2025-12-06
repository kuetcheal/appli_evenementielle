import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/events_provider.dart';

class NearbyEventsSection extends StatefulWidget {
  const NearbyEventsSection({Key? key}) : super(key: key);

  @override
  State<NearbyEventsSection> createState() => _NearbyEventsSectionState();
}

class _NearbyEventsSectionState extends State<NearbyEventsSection> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // On initialise une seule fois
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
    final userProvider = Provider.of<UserProvider>(context);
    final mail = userProvider.user?["mail"]?.toString() ?? "";

    if (mail.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Connectez-vous pour voir les événements près de chez vous.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      );
    }

    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, _) {
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

        final nearby = eventsProvider.nearbyEvents;

        if (nearby.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Aucun événement proche trouvé pour le moment.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Événements près de chez vous",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Liste des events (non scrollable, s'intègre dans un scroll parent)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nearby.length,
                itemBuilder: (context, index) {
                  final event = nearby[index];

                  final title = event["title"] ?? "Sans titre";
                  final location = event["location"] ?? "";
                  final city = event["city"] ?? "";
                  final distance = event["distance"] as double?;
                  final imageUrl = event["image_url"]?.toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        // TODO: navigation vers la page détail de l'event
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image de l'event
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.network(
                                imageUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Colors.white,
                              ),
                            ),

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$location, $city",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (distance != null)
                                    Text(
                                      "${distance.toStringAsFixed(1)} km de chez vous",
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
