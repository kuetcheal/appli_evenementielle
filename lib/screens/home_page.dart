import 'package:flutter/material.dart';
import 'authentification/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 👇 Fake events
  final List<Map<String, String>> _events = [
    {"title": "Concert Georgien", "location": "Place de la Comédie, Montpellier"},
    {"title": "Cuisine avec Cyrille", "location": "Rondelet"},
    {"title": "Salon Tech 2025", "location": "Parc Expo"},
    {"title": "Festival Culinaire", "location": "Montpellier Centre"},
    {"title": "Conférence IA", "location": "Université de Montpellier"},
  ];

  @override
  Widget build(BuildContext context) {
    // Pages de navigation (les vraies pages à remplacer plus tard)
    final List<Widget> _pages = [
      _buildDiscoverPage(),
      const Center(child: Text("Plan Page")),
      const Center(child: Text("Événements Page")),
      const LoginPage(), // 👈 profil envoie vers Login
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Découvrir",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Événements",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  /// ✅ Page Découvrir
  Widget _buildDiscoverPage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
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
                  label: const Text("Filtres", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Catégories (chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip("Concerts", Colors.red),
                  _buildCategoryChip("Salons", Colors.orange),
                  _buildCategoryChip("Culinaire", Colors.green),
                  _buildCategoryChip("Art", Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section A venir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "À venir",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("Voir tout >", style: TextStyle(color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 10),

            // Liste horizontale d’événements
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return _buildEventCard(_events[index]);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Section à proximité
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "À proximité de vous",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("Voir tout >", style: TextStyle(color: Colors.blueAccent)),
              ],
            ),
            // 👉 tu pourras ajouter une autre liste plus tard
          ],
        ),
      ),
    );
  }

  /// ✅ Widget pour un événement
  Widget _buildEventCard(Map<String, String> event) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              "assets/concert.png", // 👈 image brute pour l'instant
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  event["location"]!,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Widget pour les catégories
  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
