import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'transport_mode_sheet.dart';

class DirectionsButton extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const DirectionsButton({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  bool get _hasCoords => latitude != null && longitude != null;

  Future<void> _openMaps(BuildContext context, String mode) async {
    if (!_hasCoords) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coordonnées GPS de l’évènement manquantes.")),
      );
      return;
    }

    final lat = latitude!;
    final lng = longitude!;

    final Uri url = Platform.isIOS
        ? Uri.parse("http://maps.apple.com/?daddr=$lat,$lng")
        : Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=$mode",
    );

    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d’ouvrir l’application de navigation.")),
      );
    }
  }

  Future<void> _onPressed(BuildContext context) async {
    if (!_hasCoords) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coordonnées GPS de l’évènement manquantes.")),
      );
      return;
    }

    final selected = await TransportModeSheet.show(context);
    if (selected == null) return;

    // iOS Apple Plans n’accepte pas "travelmode" pareil que Google
    // On ouvre Apple Plans sans mode, Google Maps avec mode.
    await _openMaps(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _onPressed(context),
        icon: const Icon(Icons.directions),
        label: const Text(
          "ITINÉRAIRE",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}