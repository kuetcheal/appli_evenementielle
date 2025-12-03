import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/category_chips.dart';
import 'widgets/events_horizontal_list.dart';
import 'widgets/invite_section.dart';
import 'widgets/nearby_section.dart';

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
    // Pour l’instant on prend tous les events.
    // Si tu ajoutes le filtrage, tu pourras mettre : eventsProvider.filteredEvents
    final events = eventsProvider.events;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Header bleu foncé
          const HomeHeader(),

          // 🔹 Contenu scrollable sous le header
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 190, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // --- PARTIE ÉVÉNEMENTS ---
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

                const SizedBox(height: 30),

                // --- BLOC "INVITE" + IMAGE ---
                const InviteSection(),

                const SizedBox(height: 40),

                // --- SECTION "À PROXIMITÉ DE VOUS" ---
                const NearbySection(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
