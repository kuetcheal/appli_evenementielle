import 'package:flutter/material.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

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
          "NOS SERVICES",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _serviceCard(
              title: "Pack gratuit",
              description: "Ce que vous obtiendrez",
              features: const [
                "Visibilité sur tous les événements à venir",
                "Prise de billets classique via l’app",
                "Géolocalisation interactive",
                "Publicité légère intégrée",
                "Accès aux avis partiels",
              ],
              price: "Plan actuel",
              isCurrent: true,
            ),
            const SizedBox(height: 20),
            _serviceCard(
              title: "Pack Découverte",
              description: "Ce que vous obtiendrez",
              features: const [
                "Tout ce que contient le pack gratuit",
                "Réduction sur certains billets",
                "Priorité dans les files d’attente",
                "Badge profil “Découverte” (effet de statut)",
              ],
              price: "4,99€/mois",
            ),
            const SizedBox(height: 20),
            _serviceCard(
              title: "Pack Premium +",
              description: "Ce que vous obtiendrez",
              features: const [
                "Tout ce que contient le pack découverte",
                "Réduction avec les partenaires hôtels / taxis",
                "Accès anticipé aux événements avant les autres",
                "Prise de billets en avance + réductions",
                "Accès à des événements “privés” (ou avant-première)",
              ],
              price: "9,99€/mois",
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard({
    required String title,
    required String description,
    required List<String> features,
    required String price,
    bool isCurrent = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0140),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  isCurrent ? "Plan actuel" : "Choisir ce plan",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          for (var f in features)
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    f,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isCurrent)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text("Choisir ce plan"),
              ),
            ),
        ],
      ),
    );
  }
}
