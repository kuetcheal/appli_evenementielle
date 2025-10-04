import 'package:flutter/material.dart';

class BilletsPage extends StatelessWidget {
  const BilletsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Billets'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Page des Billets',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
