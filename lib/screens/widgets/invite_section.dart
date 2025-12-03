// lib/screens/widgets/invite_section.dart
import 'package:flutter/material.dart';

class InviteSection extends StatelessWidget {
  const InviteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: action du bouton INVITE
            },
            child: const Text(
              "INVITE",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Image.asset(
            "assets/cadeau1.png",
            height: 150,
            width: 190,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
