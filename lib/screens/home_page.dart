import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/category_chips.dart';
import 'widgets/events_horizontal_list.dart';
import 'widgets/nearby_section.dart';
import 'widgets/home_favoris.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // 🔄 Charger les events au démarrage
    Future.microtask(() =>
        Provider.of<EventsProvider>(context, listen: false).fetchEvents());
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final events = eventsProvider.filteredEvents;

    // ✅ bg-color comme ton écran "Événements à venir"
    const pageBg = Color(0xFFF7F6FB);

    return Scaffold(
      backgroundColor: pageBg,
      body: Container(
        color: pageBg, // (au cas où)
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER
              const HomeHeader(),

              const SizedBox(height: 16),

              // --- CATEGORIES ---
              const CategoryChips(),
              const SizedBox(height: 16),

              // --- SECTION "À VENIR" ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "À venir",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Voir tout >",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // --- PARTIE ÉVÉNÉMENTS ---
              if (eventsProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (eventsProvider.error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    eventsProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else
                EventsHorizontalList(events: events),

              const SizedBox(height: 40),

              // --- SECTION "À PROXIMITÉ DE VOUS" ---
              const NearbySection(),

              const SizedBox(height: 40),

              // --- SECTION "MES FAVORIS" ---
              const HomeFavorisSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
