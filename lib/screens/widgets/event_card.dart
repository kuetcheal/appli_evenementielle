// lib/screens/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';

// ✅ Import de la page détails
import '../evenement/detail_event_page.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({super.key, required this.event});

  bool _isValidHttpUrl(dynamic value) {
    if (value == null) return false;
    final s = value.toString().trim();
    if (s.isEmpty) return false;
    if (s.toLowerCase() == "null") return false;
    return s.startsWith("http://") || s.startsWith("https://");
  }

  // ✅ Format: "Sam, Oct 25 • 8:30 PM"
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
    const months = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final dayNum = date.day;

    if (hour == null || minute == null) {
      return "$dayName, $monthName $dayNum";
    }

    final isPm = hour >= 12;
    int h12 = hour % 12;
    if (h12 == 0) h12 = 12;
    final mm = minute.toString().padLeft(2, "0");

    return "$dayName, $monthName $dayNum • $h12:$mm ${isPm ? "PM" : "AM"}";
  }

  Widget _eventImage(dynamic imageUrl) {
    final hasNetworkImage = _isValidHttpUrl(imageUrl);

    if (!hasNetworkImage) {
      return Image.asset(
        "assets/concert.png",
        height: 145,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl.toString(),
      height: 145,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          height: 145,
          width: double.infinity,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  (loadingProgress.expectedTotalBytes!)
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/concert.png",
          height: 145,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final dynamic imageUrl = event["image_url"];
    final dateLine = _formatEventDateLine(event);

    return Container(
      height: 240, // ✅ hauteur inchangée
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eventImage(imageUrl),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Titre + Favoris à droite
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (event["titre"] ?? event["title"] ?? "Sans titre")
                            .toString(),
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
                        (event["isFavorite"] ?? false)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.purple,
                        size: 22,
                      ),
                      onPressed: () =>
                          eventsProvider.toggleFavorite(event["id"] as int),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // ✅ Date
                if (dateLine.isNotEmpty)
                  Text(
                    dateLine,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 6),

                // ✅ 25 participants + Détails
                Row(
                  children: [
                    const Text(
                      "25 participants",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailEventPage(event: event),
                          ),
                        );
                      },
                      child: const Text(
                        "Détails",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ✅ Adresse
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
                        (event["lieu"] ??
                            event["location"] ??
                            "Lieu non renseigné")
                            .toString(),
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
  }
}
