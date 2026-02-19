import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../providers/user_provider.dart';
import '../../providers/events_provider.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _gpsLoading = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _useGpsCurrentLocation(BuildContext context) async {
    if (_gpsLoading) return;

    setState(() => _gpsLoading = true);

    final userProvider = context.read<UserProvider>();
    final eventsProvider = context.read<EventsProvider>();

    try {
      // 0) Vérifier que le GPS est activé
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Active la localisation (GPS) sur ton téléphone.")),
          );
        }
        return;
      }

      // 1) Permissions
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission GPS refusée.")),
          );
        }
        return;
      }

      // 2) Position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3) Reverse geocode => adresse réelle
      String label = "Position actuelle";
      String postalCode = "";
      String city = "";

      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          postalCode = (p.postalCode ?? "").trim();
          city = (p.locality ?? "").trim();

          final street = (p.street ?? "").trim();
          label = [street, city].where((x) => x.trim().isNotEmpty).join(", ");
          if (label.trim().isEmpty) label = "Position actuelle";
        }
      } catch (_) {}

      // 4) Update provider (header)
      await userProvider.useCurrentLocationAsAddress(
        labelAddress: label,
        postalCode: postalCode,
        city: city,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      // 5) Recalcul nearby sur coords
      await eventsProvider.fetchNearbyEventsByCoords(
        lat: pos.latitude,
        lng: pos.longitude,
        radiusKm: 25,
      );

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur GPS: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // Adresse “profil”
    final currentAdresse = userProvider.user?["Adresse"]?.toString() ?? "Adresse inconnue";
    final currentCP = userProvider.user?["code_postal"]?.toString() ?? "";
    final currentCity = userProvider.user?["city"]?.toString() ?? "";

    final history = userProvider.addressHistory;

    final q = _searchCtrl.text.trim().toLowerCase();
    final filteredHistory = q.isEmpty
        ? history
        : history.where((a) {
      final full = "${a.address} ${a.postalCode} ${a.city}".toLowerCase();
      return full.contains(q);
    }).toList();

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
          "Adresses",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        children: [
          // 🔎 Barre recherche
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.search),
                hintText: "Rechercher une adresse",
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Adresses à proximité",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _AddressTile(
            icon: Icons.location_on_outlined,
            title: currentCity.isNotEmpty ? currentCity : currentAdresse,
            subtitle: "$currentAdresse${currentCP.isNotEmpty ? ", $currentCP" : ""}",
            trailing: Icons.edit_outlined,
            onTap: () async {
              await userProvider.setCurrentAddress(
                address: currentAdresse,
                postalCode: currentCP,
                city: currentCity,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),

          const SizedBox(height: 22),

          const Text(
            "Adresses précédentes",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (filteredHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Aucune adresse enregistrée.",
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ...filteredHistory.map((a) => _AddressTile(
              icon: Icons.history,
              title: a.address,
              subtitle: "${a.postalCode}${a.city.isNotEmpty ? ", ${a.city}" : ""}",
              trailing: Icons.edit_outlined,
              onTap: () async {
                await userProvider.setCurrentAddress(
                  address: a.address,
                  postalCode: a.postalCode,
                  city: a.city,
                  latitude: a.latitude,
                  longitude: a.longitude,
                );
                if (context.mounted) Navigator.pop(context);
              },
            )),

          const SizedBox(height: 22),

          const Text(
            "Votre position actuelle",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _AddressTile(
            icon: Icons.my_location,
            title: _gpsLoading ? "Récupération en cours..." : "Utiliser ma position actuelle",
            subtitle: "GPS • Mettre à jour automatiquement",
            trailing: _gpsLoading ? Icons.hourglass_top : Icons.chevron_right,
            onTap: _gpsLoading ? () {} : () => _useGpsCurrentLocation(context),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;

  const _AddressTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              Icon(trailing, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
