import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/events_provider.dart';
import '../evenement/detail_event_page.dart';
import '../profile/favoris_page.dart'; // ✅ ajoute cet import

class HomeFavorisSection extends StatelessWidget {
  const HomeFavorisSection({Key? key}) : super(key: key);

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
    final provider = context.watch<EventsProvider>();
    final favoris = provider.favorites;

    if (favoris.isEmpty) {
      // ✅ On garde l’état vide, mais on affiche aussi "Voir tout >"
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Mes favoris",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavorisPage()),
                    );
                  },
                  child: const Text(
                    "Voir tout >",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Aucun favori pour le moment ❤️",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Titre + Voir tout >
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mes favoris",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavorisPage()),
                  );
                },
                child: const Text(
                  "Voir tout >",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 255,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favoris.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final e = favoris[index];

              final id = e["id"] is int ? e["id"] as int : int.tryParse("${e["id"]}");
              final title = (e["titre"] ?? e["title"] ?? "Sans titre").toString();
              final location = (e["lieu"] ?? e["location"] ?? "Lieu non renseigné").toString();
              final imageUrl = e["image_url"];
              final dateLine = _formatEventDateLine(e);
              final distance = _safeDistance(e["distance"]);
              final isFavorite = (e["isFavorite"] ?? false) == true;

              return Container(
                width: 220,
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
                                onPressed: id == null ? null : () => provider.toggleFavorite(id),
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
  }
}
