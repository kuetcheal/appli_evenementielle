import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class SurroundingPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final String category;

  const SurroundingPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    required this.category,
  });

  factory SurroundingPlace.fromJson(Map<String, dynamic> json) {
    return SurroundingPlace(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "Lieu sans nom",
      address: json["address"]?.toString() ?? "",
      latitude: double.tryParse(json["latitude"].toString()) ?? 0,
      longitude: double.tryParse(json["longitude"].toString()) ?? 0,
      rating: json["rating"] == null
          ? null
          : double.tryParse(json["rating"].toString()),
      category: json["category"]?.toString() ?? "other",
    );
  }
}

class EventSurroundingsService {
  static String get _baseUrl => AppConfig.apiUrl;

  static Future<List<SurroundingPlace>> fetchPlaces({
    required double lat,
    required double lng,
    required String category,
    int radius = 800,
  }) async {
    final uri = Uri.parse("$_baseUrl/api/maps/event-surroundings").replace(
      queryParameters: {
        "lat": lat.toString(),
        "lng": lng.toString(),
        "category": category,
        "radius": radius.toString(),
      },
    );

    final response = await http.get(uri);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      final List<dynamic> places = data["places"] ?? [];

      return places
          .map((item) => SurroundingPlace.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .where((p) => p.latitude != 0 && p.longitude != 0)
          .toList();
    }

    throw Exception(
      data["message"]?.toString() ??
          "Impossible de récupérer les lieux proches.",
    );
  }
}