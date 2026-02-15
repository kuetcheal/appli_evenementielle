import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/user_provider.dart';
import '../evenement/detail_event_page.dart';

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

  bool _isValidHttpUrl(dynamic value) {
    if (value == null) return false;
    final s = value.toString().trim();
    if (s.isEmpty) return false;
    if (s.toLowerCase() == "null") return false;
    return s.startsWith("http://") || s.startsWith("https://");
  }

  String _formatEventDateLine(Map<String, dynamic> e) {
    final rawDate = e["date_event"];
    final rawTime = e["time_event"];

    if (rawDate == null || rawDate.toString().trim().isEmpty) return "";

    DateTime? date;
    try {
      date = DateTime.parse(rawDate.toString());
    } catch (_) {
      return "";
    }

    int? hour;
    int? minute;
    if (rawTime != null && rawTime.toString().trim().isNotEmpty) {
      final t = rawTime.toString().trim();
      final parts = t.split(":");
      if (parts.length >= 2) {
        hour = int.tryParse(parts[0]);
        minute = int.tryParse(parts[1]);
      }
    }

    const days = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final dayNum = date.day;

    if (hour == null || minute == null) return "$dayName, $monthName $dayNum";

    final isPm = hour >= 12;
    int h12 = hour % 12;
    if (h12 == 0) h12 = 12;
    final mm = minute.toString().padLeft(2, "0");

    return "$dayName, $monthName $dayNum • $h12:$mm ${isPm ? "PM" : "AM"}";
  }

  Widget _eventImage(dynamic imageUrl) {
    const h = 110.0;

    final hasNetworkImage = _isValidHttpUrl(imageUrl);

    if (!hasNetworkImage) {
      return Image.asset(
        "assets/concert.png",
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl.toString(),
      height: h,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          height: h,
          width: double.infinity,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/concert.png",
          height: h,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
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
              "Aucun événement proche (≤ 25 km) pour le moment.",
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

            // ✅ on augmente la hauteur globale pour éviter TOUT overflow
            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final e = events[index];

                  final id = _safeId(e["id"]);
                  final title = (e["titre"] ?? e["title"] ?? "Sans titre").toString();
                  final location = (e["lieu"] ?? e["location"] ?? "Lieu non renseigné").toString();
                  final imageUrl = e["image_url"];
                  final dateLine = _formatEventDateLine(e);
                  final distance = _safeDistance(e["distance"]);
                  final isFavorite = (e["isFavorite"] ?? false) == true;

                  return Container(
                    width: 220,
                    // ✅ on fixe une hauteur un peu plus grande que le contenu
                    height: 245,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _eventImage(imageUrl),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1) Titre + favoris
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.purple,
                                      size: 22,
                                    ),
                                    onPressed: id == null ? null : () => eventsProvider.toggleFavorite(id),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 2),

                              // 2) Date + Détails (sans soulignement)
                              if (dateLine.isNotEmpty)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dateLine,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetailEventPage(event: e),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Détails",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          // ✅ plus de underline
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 6),

                              // 3) À ? de chez vous
                              if (distance != null)
                                Text(
                                  "À ${distance.toStringAsFixed(1)} km de chez vous",
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              else
                                const SizedBox(height: 16),

                              const SizedBox(height: 6),

                              // 4) Adresse
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
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
