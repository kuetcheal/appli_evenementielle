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


#### gestion de l'ittineraire
La fonctionnalité d’itinéraire a été implémentée via un composant dédié (DirectionsButton) chargé de gérer
l’interaction utilisateur et l’ouverture de l’application de navigation. Lors du clic, un BottomSheet
permet à l’utilisateur de sélectionner un mode de transport (voiture, marche, transport en commun). Le mode choisi est ensuite injecté 
dans une URL de type Google Maps Directions API contenant les coordonnées GPS de l’événement. Cette URL est générée dynamiquement
à partir des données de l’événement et ouverte via le package url_launcher en mode application externe. Le calcul du trajet,
l’estimation de la durée et l’affichage cartographique sont entièrement délégués à Google Maps, tandis que 
l’application conserve uniquement la responsabilité de la génération des paramètres et du déclenchement de la navigation.