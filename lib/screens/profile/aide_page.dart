import 'package:flutter/material.dart';

class AidePage extends StatefulWidget {
  const AidePage({super.key});

  @override
  State<AidePage> createState() => _AidePageState();
}

class _AidePageState extends State<AidePage> {
  final List<Map<String, String>> faqs = [
    {
      "question": "Qu'est-ce que l'application EasyTravel ?",
      "answer":
      "EasyTravel est une plateforme qui permet d’accéder facilement à des événements, hébergements et services partenaires."
    },
    {
      "question": "Comment modifier mon profil ?",
      "answer":
      "Vous pouvez modifier vos informations depuis la section Profil > Modifier mon profil."
    },
    {
      "question": "Comment supprimer mon compte ?",
      "answer":
      "Allez dans Profil > Supprimer mon compte et confirmez votre choix."
    },
    {
      "question": "Comment contacter l’assistance ?",
      "answer":
      "Rendez-vous dans la page 'Contactez-nous' pour envoyer un message à notre équipe de support."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F0FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "FAQ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search Help",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Frequently Asked Questions",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return ExpansionTile(
                    title: Text(
                      faq["question"]!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          faq["answer"]!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
