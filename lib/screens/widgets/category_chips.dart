// lib/screens/widgets/category_chips.dart
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          _CategoryChip(
            label: "Concerts",
            color: Colors.red,
            icon: Icons.music_note,
          ),
          _CategoryChip(
            label: "Salons",
            color: Colors.orange,
            icon: Icons.store,
          ),
          _CategoryChip(
            label: "Culinaire",
            color: Colors.green,
            icon: Icons.restaurant,
          ),
          _CategoryChip(
            label: "Art",
            color: Colors.blue,
            icon: Icons.brush,
          ),
          _CategoryChip(
            label: "Sport",
            color: Colors.deepPurple,
            icon: Icons.sports_soccer, // ⚽ ballon de foot
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

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
