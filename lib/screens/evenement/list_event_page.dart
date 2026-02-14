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
    Future.microtask(() =>
        Provider.of<EventsProvider>(context, listen: false).fetchEvents());
  }

  // ✅ Même format que EventCard
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
                  (loadingProgress.expectedTotalBytes!)
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

  // ✅ petit helper: titre de type propre
  String _prettyType(String? raw) {
    final t = (raw ?? "").toString().trim().toLowerCase();
    if (t.isEmpty || t == "null") return "Autre";
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventsProvider>(context);

    // ✅ on récupère tous les events
    final events = provider.events;

    // ✅ on groupe par event_type
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final e in events) {
      final key = _prettyType(e["event_type"]);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(e);
    }

    // ✅ ordre d’affichage (tu peux ajuster)
    final preferredOrder = ["Sport", "Concert", "Salon", "Culinaire", "Art", "Autre"];
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
      appBar: AppBar(
        title: const Text(
          "Événements à venir",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: types.length,
        itemBuilder: (context, typeIndex) {
          final type = types[typeIndex];
          final items = grouped[type] ?? [];

          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Titre de section (type)
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 8),
                child: Text(
                  type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              // ✅ Liste des events de ce type
              ...items.map((event) {
                final formattedDateTime = _formatEventDateLine(event);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailEventPage(event: event),
                      ),
                    );
                  },
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDateTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (event["title"] ?? "Sans titre")
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16,
                                        color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${event['location'] ?? ''}${event['city'] != null && event['city'].toString().isNotEmpty ? ', ${event['city']}' : ''}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              const Icon(Icons.more_horiz,
                                  color: Colors.grey),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailEventPage(event: event),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Détails",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 6),
            ],
          );
        },
      ),
    );
  }
}
