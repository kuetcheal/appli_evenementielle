import 'package:flutter/material.dart';

class DistanceBadge extends StatelessWidget {
  final double distanceKm;

  const DistanceBadge({
    super.key,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final txt = distanceKm >= 1
        ? "${distanceKm.toStringAsFixed(1)} km de vous"
        : "${(distanceKm * 1000).toStringAsFixed(0)} m de vous";

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.near_me, size: 16, color: Color(0xFF6C63FF)),
          const SizedBox(width: 8),
          Text(
            txt,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }
}