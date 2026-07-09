import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/events_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/category_chips.dart';
import 'widgets/events_horizontal_list.dart';
import 'widgets/nearby_section.dart';
import 'widgets/home_favoris.dart';
import 'widgets/popular_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = Provider.of<EventsProvider>(context, listen: false);

      provider.fetchEvents();
      provider.fetchPopularEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final events = eventsProvider.filteredEvents;

    const pageBg = Color(0xFFF7F6FB);

    return Scaffold(
      backgroundColor: pageBg,
      body: Container(
        color: pageBg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),

              const SizedBox(height: 16),

              const CategoryChips(),

              const SizedBox(height: 16),

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

              const PopularSection(),

              const SizedBox(height: 40),

              const NearbySection(),

              const SizedBox(height: 40),

              const HomeFavorisSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}