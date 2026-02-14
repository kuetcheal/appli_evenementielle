import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/events_provider.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventsProvider>(context);
    final selected = provider.selectedType; // ex: "sport", "concert", null

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // ✅ reset filtre
          _CategoryChip(
            label: "Tous",
            color: Colors.grey,
            icon: Icons.all_inclusive,
            selected: selected == null,
            onTap: () => provider.setSelectedType(null),
          ),
          _CategoryChip(
            label: "Concerts",
            color: Colors.red,
            icon: Icons.music_note,
            selected: selected == "concert",
            onTap: () => provider.setSelectedType("concert"),
          ),
          _CategoryChip(
            label: "Salons",
            color: Colors.orange,
            icon: Icons.store,
            selected: selected == "salon",
            onTap: () => provider.setSelectedType("salon"),
          ),
          _CategoryChip(
            label: "Culinaire",
            color: Colors.green,
            icon: Icons.restaurant,
            selected: selected == "culinaire",
            onTap: () => provider.setSelectedType("culinaire"),
          ),
          _CategoryChip(
            label: "Art",
            color: Colors.blue,
            icon: Icons.brush,
            selected: selected == "art",
            onTap: () => provider.setSelectedType("art"),
          ),
          _CategoryChip(
            label: "Sport",
            color: Colors.deepPurple,
            icon: Icons.sports_soccer,
            selected: selected == "sport",
            onTap: () => provider.setSelectedType("sport"),
          ),
          _CategoryChip(
            label: "Autre",
            color: Colors.brown,
            icon: Icons.category,
            selected: selected == "autre",
            onTap: () => provider.setSelectedType("autre"),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.55),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
