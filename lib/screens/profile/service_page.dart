import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../authentification/login_page.dart';
import '../paiement/ticket_webview_page.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  Future<void> _choosePlan({
    required BuildContext context,
    required String planCode,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (userProvider.user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
      return;
    }

    final url = await paymentProvider.createSubscriptionSession(
      planCode: planCode,
    );

    if (!context.mounted) return;

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paymentProvider.errorMessage ??
                "Impossible de lancer le paiement Stripe.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketWebViewPage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _serviceCard(
                  context: context,
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
                  context: context,
                  title: "Pack Découverte",
                  description: "Ce que vous obtiendrez",
                  features: const [
                    "Tout ce que contient le pack gratuit",
                    "Réduction sur certains billets",
                    "Priorité dans les files d’attente",
                    "Badge profil “Découverte”",
                  ],
                  price: "4,99€/mois",
                  planCode: "decouverte",
                ),

                const SizedBox(height: 20),

                _serviceCard(
                  context: context,
                  title: "Pack Premium +",
                  description: "Ce que vous obtiendrez",
                  features: const [
                    "Tout ce que contient le pack découverte",
                    "Réduction avec les partenaires hôtels / taxis",
                    "Accès anticipé aux événements",
                    "Prise de billets en avance + réductions",
                    "Accès à des événements privés ou avant-première",
                  ],
                  price: "9,99€/mois",
                  planCode: "premium",
                ),
              ],
            ),
          ),

          if (paymentProvider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.pinkAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _serviceCard({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> features,
    required String price,
    String? planCode,
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
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  isCurrent ? "Plan actuel" : "Choisir ce plan",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
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

          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
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
                onPressed: planCode == null
                    ? null
                    : () => _choosePlan(
                  context: context,
                  planCode: planCode,
                ),
                child: const Text(
                  "Choisir ce plan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}