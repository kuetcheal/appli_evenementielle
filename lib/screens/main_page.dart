import 'package:flutter/material.dart';
import 'home_page.dart';
import 'evenement/list_event_page.dart';
import 'profile/profile_page.dart'; // ✅ chemin corrigé

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Pages associées à chaque onglet
  final List<Widget> _pages = const [
    HomePage(),                                // Découvrir
    Center(child: Text("Plan (à venir)")),     // Plan
    ListEventPage(),                           // Événements
    ProfilePage(),                              // ✅ Profil dynamique
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // effet flottant de la barre
      body: _pages[_currentIndex],

      // ---- Barre de navigation inférieure ----
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ---- Conteneur de la barre ----
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.purple,
                unselectedItemColor: Colors.black54,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_rounded),
                    label: 'Découvrir',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_rounded),
                    label: 'Plan',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border_rounded),
                    label: 'Événements',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profil',
                  ),
                ],
              ),
            ),

            // ---- Badge Home décoratif (au centre, surélevé) ----
            Positioned(
              top: -24,
              left: 0,
              right: 0,
              child: Center(child: _homeBadge()),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Icône centrale (home) ----
  Widget _homeBadge() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 0,
            spreadRadius: -4, // halo clair
          ),
        ],
      ),
      child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
    );
  }
}
