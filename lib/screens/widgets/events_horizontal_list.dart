// lib/screens/widgets/events_horizontal_list.dart
import 'package:flutter/material.dart';
import 'event_card.dart';

class EventsHorizontalList extends StatefulWidget {
  final List<Map<String, dynamic>> events;

  const EventsHorizontalList({super.key, required this.events});

  @override
  State<EventsHorizontalList> createState() => _EventsHorizontalListState();
}

class _EventsHorizontalListState extends State<EventsHorizontalList> {
  final ScrollController _controller = ScrollController();
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        final maxScroll = _controller.position.maxScrollExtent;
        _scrollPosition =
        maxScroll > 0 ? _controller.offset / maxScroll : 0.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events;

    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Aucun évènement disponible."),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            separatorBuilder: (context, index) =>
            const SizedBox(width: 20),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 255,
                child: EventCard(event: events[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Barre de progression
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final count = events.isEmpty ? 1 : events.length;
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
                    widthFactor: (1 / count) +
                        (_scrollPosition * (1 - (1 / count))),
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
      ],
    );
  }
}
