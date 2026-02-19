# application_voyage

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### utilisation de .env grâce à flutter pub add flutter_dotenv
il me servira comme point d'entrée de notre API Backend NodeJS  disponible sur Render


### Cloudinary est une très bonne solution pour gérer tes images (Node.js + Flutter) :
c'est utile pour le stockage, les URLs publiques, le redimensionnement, l'optimisation, etc.



#### utilisation de geolocator et geocode pour la géolocalisation
Gestion dynamique de l’adresse utilisateur (GPS & adresse manuelle)
Dans le cadre du développement de l’application mobile Flutter, la gestion de la localisation utilisateur a été implémentée à l’aide des packages Geolocator et Geocoding.
🔹 1. Récupération de la position GPS (Geolocator)
Le package Geolocator a été utilisé pour :
Gérer les permissions système (demande et vérification des autorisations GPS).
Récupérer les coordonnées géographiques précises de l’utilisateur (latitude, longitude) via :
Geolocator.getCurrentPosition()
Ces coordonnées sont ensuite exploitées pour :
Mettre à jour dynamiquement l’adresse active dans l’application.
Recalculer la distance entre l’utilisateur et les événements disponibles.

🔹 2. Reverse Geocoding (Geocoding)
Le package Geocoding permet de convertir des coordonnées GPS en adresse lisible (Reverse Geocoding) :
placemarkFromCoordinates(latitude, longitude)
Les informations récupérées incluent :Rue ,Ville ,Code postal
Ces données sont utilisées pour :
- Mettre à jour l’affichage de l’adresse dans l’interface (header).
- Enregistrer temporairement l’adresse GPS sélectionnée.
- Offrir une meilleure expérience utilisateur avec une adresse compréhensible.

🔹 3. Gestion multi-source de localisation
Deux modes de localisation sont gérés :
Adresse profil (stockée en base de données)
Géocodée côté backend lors de l’inscription.
Utilisée par défaut pour le calcul des distances.
Position GPS en temps réel
Prioritaire lorsqu’elle est activée.
Transmise au backend via lat et lng pour recalculer dynamiquement les distances.

🔹 4. Calcul des distances
Le backend utilise la formule de Haversine (calcul sphérique)
en SQL pour déterminer la distance entre l’utilisateur et les événements.
Cette approche permet :
- Un calcul optimisé directement en base de données.
- Un filtrage des événements dans un rayon défini (ex : 25 km).
- Un tri automatique par proximité.