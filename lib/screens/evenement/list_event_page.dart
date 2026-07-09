import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/events_provider.dart';
import 'detail_event_page.dart';

class ListEventPage extends StatefulWidget {
  const ListEventPage({Key? key}) : super(key: key);

  @override
  State<ListEventPage> createState() => _ListEventPageState();
}

class _ListEventPageState extends State<ListEventPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<EventsProvider>(context, listen: false).fetchEvents();
    });
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
    const months = [
      "Jan",
      "Fév",
      "Mar",
      "Avr",
      "Mai",
      "Juin",
      "Juil",
      "Août",
      "Sep",
      "Oct",
      "Nov",
      "Déc"
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final dayNum = date.day;

    if (hour == null || minute == null) {
      return "$dayName $dayNum $monthName";
    }

    final hh = hour.toString().padLeft(2, "0");
    final mm = minute.toString().padLeft(2, "0");

    // ✅ Format plus court pour éviter le débordement
    return "$dayName $dayNum $monthName • $hh:$mm";
  }

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
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return SizedBox(
          width: 90,
          height: 90,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/concert.png",
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        );
      },
    );
  }

  String _prettyType(dynamic raw) {
    final t = (raw ?? "").toString().trim().toLowerCase();

    if (t.isEmpty || t == "null") return "Autre";

    return t[0].toUpperCase() + t.substring(1);
  }

  void _openDetails(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailEventPage(event: event),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final formattedDateTime = _formatEventDateLine(event);

    final title = (event["title"] ?? "Sans titre").toString();

    final location =
        "${event['location'] ?? ''}${event['city'] != null && event['city'].toString().isNotEmpty ? ', ${event['city']}' : ''}";

    return GestureDetector(
      onTap: () => _openDetails(event),
      child: Container(
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
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    if (formattedDateTime.isNotEmpty)
                      Text(
                        formattedDateTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 6),

                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.trim().isEmpty
                                ? "Lieu non renseigné"
                                : location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 52,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                      size: 22,
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => _openDetails(event),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Détails",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventsProvider>(context);
    final events = provider.events;

    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final e in events) {
      final key = _prettyType(e["event_type"]);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(e);
    }

    final preferredOrder = [
      "Sport",
      "Concert",
      "Salon",
      "Culinaire",
      "Art",
      "Autre",
    ];

    final types = grouped.keys.toList();

    types.sort((a, b) {
      final ia = preferredOrder.indexOf(a);
      final ib = preferredOrder.indexOf(b);

      if (ia == -1 && ib == -1) return a.compareTo(b);
      if (ia == -1) return 1;
      if (ib == -1) return -1;

      return ia.compareTo(ib);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        title: const Text(
          "Événements à venir",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      )
          : events.isEmpty
          ? const Center(
        child: Text(
          "Aucun événement disponible.",
          style: TextStyle(color: Colors.black54),
        ),
      )
          : ListView.builder(
        // ✅ top : espace après l’AppBar
        // ✅ bottom : espace pour éviter que la bottom bar cache les cards
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 140),
        itemCount: types.length,
        itemBuilder: (context, typeIndex) {
          final type = types[typeIndex];
          final items = grouped[type] ?? [];

          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                const EdgeInsets.only(bottom: 10, top: 8),
                child: Text(
                  type.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              ...items.map(_buildEventCard).toList(),

              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}