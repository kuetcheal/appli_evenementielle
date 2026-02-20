import 'package:flutter/material.dart';

class EventResultCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventResultCard({super.key, required this.event});

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
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl.toString(),
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        "assets/concert.png",
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
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
      final parts = rawTime.toString().split(":");
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

    if (hour == null || minute == null) {
      return "$dayName, $monthName $dayNum";
    }

    final isPm = hour >= 12;
    int h12 = hour % 12;
    if (h12 == 0) h12 = 12;
    final mm = minute.toString().padLeft(2, "0");

    return "$dayName, $monthName $dayNum • $h12:$mm ${isPm ? "PM" : "AM"}";
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _formatEventDateLine(event);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _eventImage(event["image_url"]),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (event["title"] ?? "Sans titre").toString(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${event['location'] ?? ''}${event['city'] != null && event['city'].toString().isNotEmpty ? ', ${event['city']}' : ''}",
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.more_horiz, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}