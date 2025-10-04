import 'package:flutter/material.dart';
import 'authentification/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  // Fake events
  final List<Map<String, String>> _events = [
    {
      "title": "Concert Georgien",
      "location": "Place de la Comédie, Montpellier",
      "participants": "+2000 participants"
    },
    {
      "title": "Cuisine avec Cyrille",
      "location": "Rondelet",
      "participants": "+8 participants"
    },
    {
      "title": "Salon Tech 2025",
      "location": "Parc Expo",
      "participants": "+120 participants"
    },
    {
      "title": "Festival Culinaire",
      "location": "Montpellier Centre",
      "participants": "+560 participants"
    },
    {
      "title": "Conférence IA",
      "location": "Université de Montpellier",
      "participants": "+300 participants"
    },
  ];

  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollPosition =
        maxScroll > 0 ? _scrollController.offset / maxScroll : 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Header bleu foncé avec arrondi bas
          Container(
            height: 230,
            decoration: const BoxDecoration(
              color: Color(0xFF0A2E44),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.notifications, color: Colors.white),
                    Column(
                      children: const [
                        Text("Current Location",
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 2),
                        Text("34000, Montpellier",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                // 🔎 Barre recherche
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Rechercher...",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      label: const Text("Filtres",
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Contenu scrollable
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 210),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Catégories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildCategoryChip("Concerts", Colors.red, Icons.music_note),
                      _buildCategoryChip("Salons", Colors.orange, Icons.store),
                      _buildCategoryChip("Culinaire", Colors.green, Icons.restaurant),
                      _buildCategoryChip("Art", Colors.blue, Icons.brush),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section A venir
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("À venir",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Voir tout >", style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 🔹 Scroll horizontal
                SizedBox(
                  height: 250,
                  child: ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _events.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 15), // gap entre cards
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 290,
                        child: _buildEventCard(_events[index]),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Barre de progression SOUS les cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 6,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (1 / _events.length) +
                                (_scrollPosition *
                                    (1 - (1 / _events.length))),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Bloc INVITE + image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("INVITE",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                      Image.asset(
                        "assets/cadeau.png",
                        height: 150,
                        width: 190,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Section À proximité
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("À proximité de vous",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Voir tout >", style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Widget Event enrichi
  Widget _buildEventCard(Map<String, String> event) {
    return Container(
      width: 290,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/concert.png",
              height: 130, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event["title"]!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),

                // ✅ Participants
                Row(
                  children: [
                    const CircleAvatar(
                        radius: 10,
                        backgroundImage: AssetImage("assets/concert.png")),
                    const SizedBox(width: 4),
                    const CircleAvatar(
                        radius: 10,
                        backgroundImage: AssetImage("assets/concert.png")),
                    const SizedBox(width: 4),
                    Text(event["participants"] ?? "+0 participants",
                        style: const TextStyle(
                            color: Colors.blueAccent, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),

                // ✅ Localisation avec icône
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(event["location"]!,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
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

  /// ✅ Widget Category
  Widget _buildCategoryChip(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
