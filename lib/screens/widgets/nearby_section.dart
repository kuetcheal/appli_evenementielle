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

  int? _safeId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  double? _safeDistance(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
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

            // ✅ Liste horizontale de cartes (même style que EventCard)
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final e = events[index];

                  final title = e["titre"] ?? e["title"] ?? "Sans titre";
                  final location = e["lieu"] ?? e["location"] ?? "Lieu non renseigné";
                  final city = e["city"]?.toString();
                  final distance = _safeDistance(e["distance"]);

                  final likes = e["likes"] ?? 0;
                  final dislikes = e["dislikes"] ?? 0;
                  final isFavorite = (e["isFavorite"] ?? false) as bool;

                  final id = _safeId(e["id"]); // important pour like/dislike/fav

                  return GestureDetector(
                    onTap: () {
                      // TODO: ouvrir page détail si tu veux
                    },
                    child: Container(
                      height: 280,
                      width: 255,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Image brute identique à EventCard
                          Image.asset(
                            "assets/concert.png",
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                // (optionnel) une ligne info sous le titre
                                if (distance != null)
                                  Text(
                                    "${distance.toStringAsFixed(1)} km de vous",
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  )
                                else if (city != null && city.isNotEmpty)
                                  Text(
                                    city,
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),

                                const SizedBox(height: 10),

                                // ✅ Likes / Dislikes / Favori (comme EventCard)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.thumb_up_alt_outlined,
                                        color: Colors.green,
                                        size: 22,
                                      ),
                                      onPressed: id == null
                                          ? null
                                          : () => eventsProvider.likeEvent(id),
                                    ),
                                    Text("$likes"),

                                    const SizedBox(width: 4),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.thumb_down_alt_outlined,
                                        color: Colors.redAccent,
                                        size: 22,
                                      ),
                                      onPressed: id == null
                                          ? null
                                          : () => eventsProvider.dislikeEvent(id),
                                    ),
                                    Text("$dislikes"),

                                    const Spacer(),

                                    IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.purple,
                                        size: 22,
                                      ),
                                      onPressed: id == null
                                          ? null
                                          : () => eventsProvider.toggleFavorite(id),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // ✅ Localisation (comme EventCard)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        location.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
