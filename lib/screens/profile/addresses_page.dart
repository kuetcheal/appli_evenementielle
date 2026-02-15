import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final currentAdresse = userProvider.user?["Adresse"]?.toString() ?? "Adresse inconnue";
    final currentCP = userProvider.user?["code_postal"]?.toString() ?? "";
    final currentCity = userProvider.user?["city"]?.toString() ?? "";

    final history = userProvider.addressHistory;

    // (optionnel) filtre simple sur le texte
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
          // 🔎 Barre recherche (comme sur ton screenshot)
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

          // ✅ Adresses à proximité (on met ton adresse actuelle)
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
              // Ici : on “re-sélectionne” l’adresse actuelle
              await userProvider.setCurrentAddress(
                address: currentAdresse,
                postalCode: currentCP,
                city: currentCity,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),

          const SizedBox(height: 22),

          // ✅ Adresses précédentes
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
                );
                if (context.mounted) Navigator.pop(context);
              },
            )),

          const SizedBox(height: 22),

          // ✅ Bloc en bas : position actuelle
          const Text(
            "Votre position actuelle",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _AddressTile(
            icon: Icons.my_location,
            title: "Utiliser ma position actuelle",
            subtitle: "GPS • Mettre à jour automatiquement",
            trailing: Icons.chevron_right,
            onTap: () async {
              // ✅ Ici tu brancheras le GPS plus tard.
              // Pour l’instant on appelle une méthode placeholder.
              await userProvider.useCurrentLocationAsAddress();
              if (context.mounted) Navigator.pop(context);
            },
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
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Icon(trailing, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
