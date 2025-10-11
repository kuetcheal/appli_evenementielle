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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventsProvider>(context);

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
        itemCount: provider.events.length,
        itemBuilder: (context, index) {
          final event = provider.events[index];

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
                  // ✅ IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: event["image_url"] != null
                        ? Image.network(
                      event["image_url"],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset(
                            "assets/concert.png",
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                    )
                        : Image.asset(
                      "assets/concert.png",
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ✅ TEXTE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${event['date_event']} • ${event['time_event']}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event["title"] ?? "Sans titre",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${event['location'] ?? ''}, ${event['city'] ?? ''}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ✅ ACTION
                  Column(
                    children: [
                      const Icon(Icons.more_horiz, color: Colors.grey),
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
          );
        },
      ),
    );
  }
}
