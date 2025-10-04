import 'package:flutter/material.dart';

class OffresPage extends StatelessWidget {
  const OffresPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres spéciales'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Page des Offres',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
