import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/events_provider.dart';
import 'events_horizontal_list.dart';

class PopularSection extends StatefulWidget {
  const PopularSection({super.key});

  @override
  State<PopularSection> createState() => _PopularSectionState();
}

class _PopularSectionState extends State<PopularSection> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      Future.microtask(() {
        if (!mounted) return;

        Provider.of<EventsProvider>(
          context,
          listen: false,
        ).fetchPopularEvents();
      });

      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final popularEvents = eventsProvider.popularEvents;

    if (eventsProvider.isLoadingPopular && popularEvents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Populaires",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (eventsProvider.popularError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          eventsProvider.popularError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (popularEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Populaires",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 10),

        EventsHorizontalList(events: popularEvents),
      ],
    );
  }
}