import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/profile_menu_item.dart';

/// Écran des paramètres
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          color: AppColors.textDark,
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Notifications
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications Push',
                  subtitle: 'Activées',
                  onTap: () =>
                      _showComingSoon(context, 'Gestion des notifications'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.email_outlined,
                  title: 'Notifications Email',
                  subtitle: 'Activées',
                  onTap: () => _showComingSoon(context, 'Notifications email'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.primary,
                  ),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Apparence
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Apparence',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Thème sombre',
                  subtitle: 'Désactivé',
                  onTap: () => _showComingSoon(context, 'Thème sombre'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.language_outlined,
                  title: 'Langue',
                  subtitle: 'Français',
                  onTap: () => _showComingSoon(context, 'Changement de langue'),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confidentialité
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Confidentialité et sécurité',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.lock_outlined,
                  title: 'Changer le mot de passe',
                  onTap: () =>
                      _showComingSoon(context, 'Changement de mot de passe'),
                  iconColor: AppColors.info,
                ),
                ProfileMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Données personnelles',
                  subtitle: 'Télécharger ou supprimer',
                  onTap: () => _showComingSoon(context, 'Gestion des données'),
                  iconColor: AppColors.info,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // À propos
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'À propos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ProfileMenuItem(
                  icon: Icons.info_outlined,
                  title: 'Version de l\'application',
                  subtitle: 'v0.6.0',
                  onTap: () {},
                  trailing: const SizedBox.shrink(),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Bientôt disponible'),
        content:
            Text('La fonctionnalité "$feature" sera disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
