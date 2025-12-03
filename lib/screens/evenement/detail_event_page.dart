import 'package:flutter/material.dart';
import '../paiement/ticket_webview_page.dart';

class DetailEventPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const DetailEventPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = event["title"] ?? "Titre de l'évènement";
    final String imagePath = event["image"] ?? "assets/concert.png";
    final String dateMain = event["dateMain"] ?? "28 Avril 2026";
    final String dateRange = event["timeRange"] ?? "Mercredi, 4:00PM - 5:30PM";
    final String locationTitle =
        event["locationTitle"] ?? (event["location"] ?? "Sud de France Arena");
    final String locationAddress =
        event["address"] ?? "36 parc expo, 34090, Montpellier";
    final String? ticketUrl = event["ticket_url"]; // ✅ URL dynamique

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ======= HERO + OVERLAYS =======
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // --- Bouton retour ---
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

                // --- Bouton favori ---
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

                // --- Étiquette ---
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

                // --- CARD flottante ---
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
                                fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ======= CONTENU =======
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
                    title: dateMain,
                    subtitle: dateRange,
                  ),
                  const SizedBox(height: 14),

                  _InfoRow(
                    icon: Icons.location_on,
                    iconBg: const Color(0xFF5AC8FA),
                    title: locationTitle,
                    subtitle: locationAddress,
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

                  const _BulletLine(
                    text:
                    "Danses traditionnelles géorgiennes en costumes colorés",
                  ),
                  const SizedBox(height: 8),
                  const _BulletLine(
                    text:
                    "Concert live avec instruments traditionnels (pandouri, doudouk)",
                  ),

                  const SizedBox(height: 30),

                  // ✅ BOUTON D’ACHAT — redirige vers la billetterie
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
                              color: Color(0xFF6C63FF).withOpacity(0.35),
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

// ========= WIDGETS PRIVÉS =========

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
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13.2),
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
  const _AvatarDot({Key? key, required this.offset, required this.label})
      : super(key: key);

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
