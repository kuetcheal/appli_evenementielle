import 'package:flutter/material.dart';

class TypeFilterDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;

  const TypeFilterDropdown({
    super.key,
    required this.events,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  List<String> _types() {
    final set = <String>{};
    for (final e in events) {
      final t = (e["event_type"] ?? "").toString().trim().toLowerCase();
      if (t.isNotEmpty && t != "null") set.add(t);
    }
    final list = set.toList()..sort();
    return list;
  }

  String _pretty(String raw) => raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1);

  @override
  Widget build(BuildContext context) {
    final items = _types();

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.black38),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text("Tous les types"),
        ),
        ...items.map((t) => DropdownMenuItem<String>(
          value: t,
          child: Text(_pretty(t)),
        )),
      ],
      onChanged: onChanged,
    );
  }
}