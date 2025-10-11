import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import 'edit_profile_page.dart'; // ✅ import vers la page d'édition du profil
import '../authentification/login_page.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (user == null)
                    const CircularProgressIndicator()
                  else
                    Text(
                      user["nom"] ?? "Utilisateur",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, color: Colors.black54, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ---------- MENU ITEMS ----------
              Expanded(
                child: ListView(
                  children: [
                    // ✅ Redirection vers EditProfilePage
                    _buildMenuItem(
                      context,
                      Icons.edit,
                      "Modifier mon profil",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditProfilePage()),
                        );
                      },
                    ),

                    _buildMenuItem(context, Icons.bookmark_border, "Mes favoris"),
                    _buildMenuItem(context, Icons.store_mall_directory_outlined,
                        "Nos services",
                        crown: true),
                    _buildMenuItem(
                        context, Icons.settings_outlined, "Paramètres"),
                    _buildMenuItem(
                        context, Icons.people_alt_outlined, "Partenaires"),
                    _buildMenuItem(
                        context, Icons.mail_outline, "Contactez-nous"),
                    _buildMenuItem(context, Icons.help_outline, "Aide & FAQs"),

                    // ✅ Popup de déconnexion
                    _buildMenuItem(context, Icons.logout, "Déconnexion",
                        color: Colors.redAccent, onTap: () {
                          _showLogoutDialog(context, userProvider);
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Widget Menu Item ----------
  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title, {
        bool crown = false,
        Color? color,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.black87, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: color ?? Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (crown) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.emoji_events_rounded,
                        size: 16, color: Colors.brown),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Popup de confirmation Déconnexion ----------
  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Déconnexion",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              "Êtes-vous sûr de vouloir vous déconnecter ?\n\nVous devrez vous reconnecter pour accéder à votre compte."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Annuler",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(context); // Ferme la popup
                await userProvider.logout();

                // ✅ Redirige vers la page de connexion
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );

                // ✅ Message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Déconnexion réussie ✅"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Se déconnecter",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
