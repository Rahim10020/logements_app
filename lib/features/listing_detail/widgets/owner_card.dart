import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';

/// Widget carte du propriétaire
class OwnerCard extends StatelessWidget {
  final UserModel owner;

  const OwnerCard({
    super.key,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Propriétaire',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Photo de profil
              CircleAvatar(
                radius: 30,
                backgroundImage: owner.photoURL.isNotEmpty
                    ? NetworkImage(owner.photoURL)
                    : null,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: owner.photoURL.isEmpty
                    ? Text(
                        owner.displayName.isNotEmpty
                            ? owner.displayName[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      owner.city,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bouton contacter
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showContactOptions(context),
              icon: const Icon(Icons.phone),
              label: const Text('Contacter le propriétaire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Afficher les options de contact
  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contacter le propriétaire',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Téléphone
                if (owner.phone.isNotEmpty)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text('Téléphone'),
                    subtitle: Text(owner.phone),
                    onTap: () => _launchPhone(owner.phone),
                  ),
                // WhatsApp
                if (owner.phone.isNotEmpty)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text('WhatsApp'),
                    subtitle: Text(owner.phone),
                    onTap: () => _launchWhatsApp(owner.phone),
                  ),
                // Email
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.email,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Email'),
                  subtitle: Text(owner.email),
                  onTap: () => _launchEmail(owner.email),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Lancer un appel téléphonique
  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Lancer WhatsApp
  Future<void> _launchWhatsApp(String phone) async {
    // Nettoyer le numéro (retirer espaces, tirets, etc.)
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Lancer l'application email
  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
