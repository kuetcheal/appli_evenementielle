import 'package:flutter/material.dart';

class PartenairePage extends StatelessWidget {
  const PartenairePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Partenaires",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ======= SECTION HEBERGEMENT =======
            const SizedBox(height: 20),
            const Text(
              "Hébergement",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/heberg.png', width: 300, height: 100, fit: BoxFit.contain),
              ],
            ),

            // ======= SECTION TRANSPORT =======
            const SizedBox(height: 30),
            const Text(
              "Transport",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/hebergement.png', width: 300, height: 100, fit: BoxFit.contain),
              ],
            ),

            // ======= SECTION SECURITE =======
            const SizedBox(height: 40),
            const Text(
              "Sécurité",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            // Liste des règles
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _securityRule(
                  icon: Icons.close,
                  color: Colors.redAccent,
                  text: "Ne pas bloquer les issues de secours",
                  backgroundColor: const Color(0xFFFFE6E6),
                ),
                const SizedBox(height: 10),
                _securityRule(
                  icon: Icons.security,
                  color: Colors.blueGrey,
                  text: "En cas de problèmes, prévenir le personnel de sécurité",
                  backgroundColor: const Color(0xFFD1E9F6),
                ),
                const SizedBox(height: 10),
                _securityRule(
                  icon: Icons.health_and_safety,
                  color: Colors.teal,
                  text: "Respectez les règles d’hygiène pour éviter la propagation de maladies",
                  backgroundColor: const Color(0xFFD4F6F0),
                ),
                const SizedBox(height: 10),
                _securityRule(
                  icon: Icons.pregnant_woman,
                  color: Colors.black87,
                  text: "Laissez la priorité aux femmes enceintes et aux personnes à mobilité réduite",
                  backgroundColor: const Color(0xFFF0F0F0),
                ),
              ],
            ),

            // ======= OBJETS INTERDITS =======
            const SizedBox(height: 40),
            const Text(
              "Objets interdits",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),

            Center(
              child: Image.asset(
                'assets/photos.jpg',
                width: double.infinity,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==== WIDGET PERSONNALISÉ POUR LES RÈGLES DE SÉCURITÉ ====
  Widget _securityRule({
    required IconData icon,
    required Color color,
    required String text,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
