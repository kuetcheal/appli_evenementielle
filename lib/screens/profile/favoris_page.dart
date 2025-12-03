import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_voyage/providers/events_provider.dart';

class FavorisPage extends StatelessWidget {
  const FavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoris = context.watch<EventsProvider>().favorites;

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
          "Mes favoris",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: favoris.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoris.length,
        itemBuilder: (context, index) {
          final event = favoris[index];
          return _FavoriCard(event: event);
        },
      ),
    );
  }

  /// --- AFFICHAGE SI AUCUN FAVORI ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border,
                size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Aucun favori pour le moment ❤️",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D0140),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Ajoutez vos événements, lieux ou offres préférés ici.",
              style: TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retour vers la page précédente
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0140),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Explorer",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _FavoriCard({required this.event});

  @override
  Widget build(BuildContext context) {
    // On récupère les champs utiles (avec valeurs par défaut)
    final titre = event["titre"] ?? event["title"] ?? "Sans titre";
    final lieu = event["lieu"] ?? event["location"] ?? "Lieu non renseigné";
    final date = event["date"] ??
        event["date_event"] ??
        "Date à venir"; // adapte si tu as un vrai champ
    final heure =
        event["heure"] ?? event["heure_event"] ?? ""; // idem ici si dispo

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Image brute à gauche (toujours la même)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.asset(
              "assets/concert.png",
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date + heure en violet (style de ton screen React)
                  Text(
                    date.toString(),
                    style: const TextStyle(
                      color: Color(0xFF8A2BE2),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  if (heure.toString().isNotEmpty)
                    Text(
                      heure.toString(),
                      style: const TextStyle(
                        color: Color(0xFF8A2BE2),
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Titre
                  Text(
                    titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Lieu + bouton "Détails"
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lieu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Naviguer vers page détail de l'évènement
                        },
                        child: const Text(
                          "Détails",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Icône poubelle pour retirer des favoris
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent),
            onPressed: () {
              // retire des favoris via le Provider
              Provider.of<EventsProvider>(context, listen: false)
                  .toggleFavorite(event["id"] as int);
            },
          ),
        ],
      ),
    );
  }
}
