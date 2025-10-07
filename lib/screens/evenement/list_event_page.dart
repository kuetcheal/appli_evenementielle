import 'package:flutter/material.dart';
import 'detail_event_page.dart';

class ListEventPage extends StatelessWidget {
  const ListEventPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> events = [
      {
        "date": "Mer, Apr 28 - 5:30 PM",
        "title": "Concert Georgien",
        "location": "Sud Arena, Montpellier",
        "image": "assets/concert.png"
      },
      {
        "date": "Sam, Mai 1 - 2:00 PM",
        "title": "Job dating",
        "location": "3, Place de la comédie",
        "image": "assets/concert.png"
      },
      {
        "date": "Sam, Apr 24 - 1:30 PM",
        "title": "Cuisine avec Cyril Lignac",
        "location": "53 rue du millénaire",
        "image": "assets/concert.png"
      },
      {
        "date": "Ven, Apr 23 - 6:00 PM",
        "title": "Final de Tournoi de foot",
        "location": "Astroc, Montpellier",
        "image": "assets/concert.png"
      },
      {
        "date": "Lun, Jun 21 - 10:00 AM",
        "title": "Journée écologique",
        "location": "14 Rue François",
        "image": "assets/concert.png"
      },
      {
        "date": "Ven, Apr 23 - 6:00 PM",
        "title": "International Kids Safe Parents",
        "location": "Lot 13 • Oakland, CA",
        "image": "assets/concert.png"
      },
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
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
                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      event["image"],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // TEXTE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event["date"],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event["title"],
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
                                event["location"],
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

                  // ACTION
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
