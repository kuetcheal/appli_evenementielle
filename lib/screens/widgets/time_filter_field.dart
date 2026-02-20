import 'package:flutter/material.dart';

class TimeFilterField extends StatelessWidget {
  final TimeOfDay? value;
  final String hintText;
  final ValueChanged<TimeOfDay?> onChanged;

  const TimeFilterField({
    super.key,
    required this.value,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final txt = value == null
        ? ""
        : value!.format(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        onChanged(t);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.schedule, color: Colors.black38),
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          txt.isEmpty ? hintText : txt,
          style: TextStyle(
            color: txt.isEmpty ? Colors.black38 : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}