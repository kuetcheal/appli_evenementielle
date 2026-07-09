import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class EventRouteResult {
  final int? distanceMeters;
  final String? distanceText;
  final String? duration;
  final String? durationText;
  final String? encodedPolyline;

  const EventRouteResult({
    this.distanceMeters,
    this.distanceText,
    this.duration,
    this.durationText,
    this.encodedPolyline,
  });

  factory EventRouteResult.fromJson(Map<String, dynamic> json) {
    return EventRouteResult(
      distanceMeters: json["distanceMeters"] is int
          ? json["distanceMeters"]
          : int.tryParse("${json["distanceMeters"]}"),
      distanceText: json["distanceText"]?.toString(),
      duration: json["duration"]?.toString(),
      durationText: json["durationText"]?.toString(),
      encodedPolyline: json["encodedPolyline"]?.toString(),
    );
  }
}

class MapsRouteService {
  static String get _baseUrl => AppConfig.apiUrl;

  static Future<EventRouteResult?> getEventRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String travelMode = "DRIVE",
  }) async {
    final uri = Uri.parse("$_baseUrl/api/maps/event-route").replace(
      queryParameters: {
        "originLat": originLat.toString(),
        "originLng": originLng.toString(),
        "destLat": destLat.toString(),
        "destLng": destLng.toString(),
        "travelMode": travelMode,
      },
    );

    final response = await http.get(uri);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      return EventRouteResult.fromJson(Map<String, dynamic>.from(data));
    }

    return null;
  }
}