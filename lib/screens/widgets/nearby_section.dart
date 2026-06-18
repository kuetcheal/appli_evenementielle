import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/events_provider.dart';
import '../../../providers/user_provider.dart';
import '../authentification/login_page.dart';
import '../evenement/detail_event_page.dart';

class NearbySection extends StatefulWidget {
  const NearbySection({Key? key}) : super(key: key);

  @override
  State<NearbySection> createState() => _NearbySectionState();
}

class _NearbySectionState extends State<NearbySection> {
  double? _lastLat;
  double? _lastLng;
  String? _lastMail;
  bool _fetchScheduled = false;

  int? _safeId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return int.tryParse(raw?.toString() ?? "");
  }

  double? _safeDistance(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return double.tryParse(raw?.toString() ?? "");
  }

  bool _isValidHttpUrl(dynamic value) {
    if (value == null) return false;
    final s = value.toString().trim();
    if (s.isEmpty) return false;
    if (s.toLowerCase() == "null") return false;
    return s.startsWith("http://") || s.startsWith("https://");
  }

  String _formatEventDateLine(Map<String, dynamic> e) {
    final rawDate = e["date_event"];
    final rawTime = e["time_event"];

    if (rawDate == null || rawDate.toString().trim().isEmpty) return "";

    DateTime? date;
    try {
      date = DateTime.parse(rawDate.toString());
    } catch (_) {
      return "";
    }

    int? hour;
    int? minute;

    if (rawTime != null && rawTime.toString().trim().isNotEmpty) {
      final t = rawTime.toString().trim();
      final parts = t.split(":");

      if (parts.length >= 2) {
        hour = int.tryParse(parts[0]);
        minute = int.tryParse(parts[1]);
      }
    }

    const days = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final dayNum = date.day;

    if (hour == null || minute == null) {
      return "$dayName, $monthName $dayNum";
    }

    final isPm = hour >= 12;
    int h12 = hour % 12;
    if (h12 == 0) h12 = 12;

    final mm = minute.toString().padLeft(2, "0");

    return "$dayName, $monthName $dayNum • $h12:$mm ${isPm ? "PM" : "AM"}";
  }

  Widget _eventImage(dynamic imageUrl) {
    const h = 110.0;
    final hasNetworkImage = _isValidHttpUrl(imageUrl);

    if (!hasNetworkImage) {
      return Image.asset(
        "assets/concert.png",
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl.toString(),
      height: h,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return const SizedBox(
          height: h,
          width: double.infinity,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/concert.png",
          height: h,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

  bool _sameCoords(double? aLat, double? aLng, double? bLat, double? bLng) {
    if (aLat == null || aLng == null || bLat == null || bLng == null) {
      return false;
    }

    return (aLat - bLat).abs() < 0.000001 && (aLng - bLng).abs() < 0.000001;
  }

  void _loadNearbyIfNeeded({
    required UserProvider userProvider,
    required EventsProvider eventsProvider,
  }) {
    if (_fetchScheduled) return;

    final lat = userProvider.displayedLatitude;
    final lng = userProvider.displayedLongitude;
    final mail = userProvider.user?["mail"]?.toString() ?? "";

    // ✅ Cas prioritaire : public par coordonnées
    if (lat != null && lng != null) {
      if (_sameCoords(_lastLat, _lastLng, lat, lng)) return;

      _lastLat = lat;
      _lastLng = lng;
      _lastMail = null;
      _fetchScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await eventsProvider.fetchNearbyEventsByCoords(
          lat: lat,
          lng: lng,
          radiusKm: 25,
        );

        if (mounted) {
          setState(() {
            _fetchScheduled = false;
          });
        }
      });

      return;
    }

    // ✅ Fallback : si utilisateur connecté mais pas de coords affichées
    if (mail.isNotEmpty) {
      if (_lastMail == mail) return;

      _lastMail = mail;
      _lastLat = null;
      _lastLng = null;
      _fetchScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await eventsProvider.fetchNearbyEvents(mail);

        if (mounted) {
          setState(() {
            _fetchScheduled = false;
          });
        }
      });
    }
  }

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  Widget _sectionTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "À proximité de vous",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionMessage(String message, {Color color = Colors.black54}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            message,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, EventsProvider>(
      builder: (context, userProvider, eventsProvider, child) {
        final lat = userProvider.displayedLatitude;
        final lng = userProvider.displayedLongitude;
        final mail = userProvider.user?["mail"]?.toString() ?? "";

        _loadNearbyIfNeeded(
          userProvider: userProvider,
          eventsProvider: eventsProvider,
        );

        final hasLocation = lat != null && lng != null;
        final hasFallbackUser = mail.isNotEmpty;

        if (!hasLocation && !hasFallbackUser) {
          return _sectionMessage(
            "Choisissez une adresse ou activez votre position pour voir les événements proches.",
          );
        }

        if (eventsProvider.isLoadingNearby &&
            eventsProvider.nearbyEvents.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        if (eventsProvider.nearbyError != null) {
          return _sectionMessage(
            eventsProvider.nearbyError!,
            color: Colors.red,
          );
        }

        final events = eventsProvider.nearbyEvents;

        if (events.isEmpty) {
          return _sectionMessage(
            "Aucun événement proche à moins de 25 km pour le moment.",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(),
            const SizedBox(height: 12),

            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final e = events[index];

                  final id = _safeId(e["id"]);
                  final title =
                  (e["titre"] ?? e["title"] ?? "Sans titre").toString();

                  final location =
                  (e["lieu"] ?? e["location"] ?? "Lieu non renseigné")
                      .toString();

                  final imageUrl = e["image_url"];
                  final dateLine = _formatEventDateLine(e);
                  final distance = _safeDistance(e["distance"]);
                  final isFavorite = (e["isFavorite"] ?? false) == true;

                  return Container(
                    width: 220,
                    height: 245,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _eventImage(imageUrl),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Titre + Favoris
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.purple,
                                      size: 22,
                                    ),
                                    onPressed: id == null
                                        ? null
                                        : () {
                                      // ✅ Favori = action privée
                                      if (userProvider.user == null) {
                                        _goToLogin(context);
                                        return;
                                      }

                                      eventsProvider.toggleFavorite(id);
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 2),

                              // Date + Détails
                              if (dateLine.isNotEmpty)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dateLine,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DetailEventPage(event: e),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Détails",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 6),

                              // Distance
                              if (distance != null)
                                Text(
                                  "À ${distance.toStringAsFixed(1)} km de chez vous",
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              else
                                const SizedBox(height: 16),

                              const SizedBox(height: 6),

                              // Adresse
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}