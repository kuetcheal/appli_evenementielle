import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../paiement/ticket_webview_page.dart';
import '../widgets/directions_button.dart';
import '../widgets/distance_badge.dart';

class DetailEventPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const DetailEventPage({Key? key, required this.event}) : super(key: key);

  @override
  State<DetailEventPage> createState() => _DetailEventPageState();
}

class _DetailEventPageState extends State<DetailEventPage> {
  Future<double?>? _distanceFuture;

  bool _isValidHttpUrl(dynamic value) {
    if (value == null) return false;
    final s = value.toString().trim();
    if (s.isEmpty) return false;
    if (s.toLowerCase() == "null") return false;
    return s.startsWith("http://") || s.startsWith("https://");
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  Future<double?> _calculateDistanceKm({
    required double? destLat,
    required double? destLng,
  }) async {
    if (destLat == null || destLng == null) return null;

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final meters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      destLat,
      destLng,
    );

    return meters / 1000.0;
  }

  // ✅ Même logique de format que dans list_event.dart
  String _formatEventDateLine(Map<String, dynamic> e) {
    final rawDate = e["date_event"];
    final rawTime = e["time_event"];

    if (rawDate == null || rawDate.toString().trim().isEmpty) {
      return "Date inconnue";
    }

    DateTime? date;
    try {
      date = DateTime.parse(rawDate.toString());
    } catch (_) {
      return "Date inconnue";
    }

    int? hour;
    int? minute;

    if (rawTime != null && rawTime.toString().trim().isNotEmpty) {
      final parts = rawTime.toString().split(":");
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

  void _openPlanEvent() {
    final dynamic rawPlanUrl =
        widget.event["plan_event_url"] ?? widget.event["plan_url"];

    if (_isValidHttpUrl(rawPlanUrl)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketWebViewPage(url: rawPlanUrl.toString()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun plan d’évènement disponible."),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    final destLat = _asDouble(widget.event["latitude"] ?? widget.event["lat"]);
    final destLng = _asDouble(widget.event["longitude"] ?? widget.event["lng"]);

    _distanceFuture = _calculateDistanceKm(destLat: destLat, destLng: destLng);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    final String title = (event["title"] ?? "Titre de l'évènement").toString();
    final String description = (event["description"] ?? "").toString();

    final String location = (event["location"] ?? "").toString();
    final String city = (event["city"] ?? "").toString();

    final String? ticketUrl = event["ticket_url"]?.toString();

    final dynamic rawImageUrl = event["image_url"];
    final bool hasNetworkImage = _isValidHttpUrl(rawImageUrl);
    final String? imageUrl = hasNetworkImage ? rawImageUrl.toString() : null;

    final double? latitude = _asDouble(event["latitude"] ?? event["lat"]);
    final double? longitude = _asDouble(event["longitude"] ?? event["lng"]);

    final String formattedDate = _formatEventDateLine(event);

    final String locationTitle =
    location.isNotEmpty ? location : "Lieu non renseigné";
    final String locationAddress =
    city.isNotEmpty ? "$city, France" : "Ville non renseignée";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: imageUrl != null
                      ? Image.network(
                    imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 260,
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes !=
                                null
                                ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes!)
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/concert.png",
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    "assets/concert.png",
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 44,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.45),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 44,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.45),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
                Positioned(
                  top: 92,
                  left: 64,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Détails de l’évènement",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -28,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 84,
                          height: 34,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: const [
                              _AvatarDot(offset: 0, label: "A"),
                              _AvatarDot(offset: 24, label: "B"),
                              _AvatarDot(offset: 48, label: "C"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7AA3FF), Color(0xFF6C63FF)],
                            ),
                          ),
                          child: const Text(
                            "+20 Going",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor:
                            const Color(0xFF6C63FF).withOpacity(0.12),
                          ),
                          child: const Text(
                            "Invite",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _InfoRow(
                    icon: Icons.calendar_today,
                    iconBg: const Color(0xFF6C63FF),
                    title: formattedDate,
                    subtitle: "Date de l’évènement",
                  ),
                  const SizedBox(height: 14),

                  _InfoRow(
                    icon: Icons.location_on,
                    iconBg: const Color(0xFF5AC8FA),
                    title: locationTitle,
                    subtitle: locationAddress,
                  ),

                  FutureBuilder<double?>(
                    future: _distanceFuture,
                    builder: (context, snapshot) {
                      final km = snapshot.data;
                      if (km == null) return const SizedBox.shrink();
                      return DistanceBadge(distanceKm: km);
                    },
                  ),

                  const SizedBox(height: 22),

                  // ✅ Deux boutons sur la même ligne
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: DirectionsButton(
                            latitude: latitude,
                            longitude: longitude,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: _GradientActionButton(
                            text: "Plan event",
                            icon: Icons.map_outlined,
                            onTap: _openPlanEvent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    "À propos de l’évènement",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14.2,
                        color: Colors.black87,
                      ),
                    )
                  else
                    const _BulletLine(
                      text: "Aucune description fournie pour cet évènement.",
                    ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        if (ticketUrl != null && ticketUrl.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TicketWebViewPage(url: ticketUrl),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Aucun lien de billetterie disponible pour cet évènement.",
                              ),
                            ),
                          );
                        }
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7A42F4), Color(0xFF6C63FF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "ACHETEZ VOTRE TICKET",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _InfoRow({
    Key? key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconBg, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13.2,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14.2),
          ),
        ),
      ],
    );
  }
}

class _AvatarDot extends StatelessWidget {
  final double offset;
  final String label;

  const _AvatarDot({
    Key? key,
    required this.offset,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset,
      child: CircleAvatar(
        radius: 17,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFE8E8FF),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A42F4), Color(0xFF6C63FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}