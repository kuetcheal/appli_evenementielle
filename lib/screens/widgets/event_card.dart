// lib/screens/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';

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

  Widget _eventImage(dynamic imageUrl) {
    final hasNetworkImage = _isValidHttpUrl(imageUrl);

    if (!hasNetworkImage) {
      return Image.asset(
        "assets/concert.png",
        height: 130,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl.toString(),
      height: 130,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          height: 130,
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
          height: 130,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);

    // ✅ on prend la vraie clé renvoyée par l’API (Cloudinary)
    final dynamic imageUrl = event["image_url"];

    return Container(
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
          // ✅ Image Cloudinary (ou fallback)
          _eventImage(imageUrl),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (event["titre"] ?? event["title"] ?? "Sans titre").toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                Text(
                  "${event["participants"] ?? ""}",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),

                // Likes / Dislikes / Favori
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.thumb_up_alt_outlined,
                        color: Colors.green,
                        size: 22,
                      ),
                      onPressed: () =>
                          eventsProvider.likeEvent(event["id"] as int),
                    ),
                    Text("${event["likes"] ?? 0}"),

                    const SizedBox(width: 4),

                    IconButton(
                      icon: const Icon(
                        Icons.thumb_down_alt_outlined,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      onPressed: () =>
                          eventsProvider.dislikeEvent(event["id"] as int),
                    ),
                    Text("${event["dislikes"] ?? 0}"),

                    const Spacer(),

                    IconButton(
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

                const SizedBox(height: 4),

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
                        (event["lieu"] ?? event["location"] ?? "Lieu non renseigné")
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
