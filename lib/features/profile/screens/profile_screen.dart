import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_menu_item.dart';

/// Écran de profil utilisateur
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.currentUser != null) {
      await profileProvider.loadProfile(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Rediriger si pas connecté
    if (authProvider.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/auth/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/profile/settings'),
            tooltip: 'Paramètres',
            color: AppColors.textDark,
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Chargement du profil...',
            );
          }

          final user = profileProvider.user;
          if (user == null) {
            return const Center(
              child: Text('Impossible de charger le profil'),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                profileProvider.refresh(authProvider.currentUser!.uid),
            color: AppColors.primary,
            child: ListView(
              children: [
                // En-tête profil
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // Menu principal
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Modifier le profil',
                        subtitle: 'Nom, téléphone, photo',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      if (user.role == 'owner')
                        ProfileMenuItem(
                          icon: Icons.dashboard_outlined,
                          title: 'Mon Dashboard',
                          subtitle: 'Gérer mes annonces',
                          onTap: () => context.push('/dashboard'),
                        ),
                      ProfileMenuItem(
                        icon: Icons.favorite_outline,
                        title: 'Mes Favoris',
                        subtitle: '${profileProvider.user?.displayName}',
                        onTap: () => context.push('/saved'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Préférences
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Gérer les notifications',
                        onTap: () => _showComingSoon('Notifications'),
                      ),
                      ProfileMenuItem(
                        icon: Icons.language_outlined,
                        title: 'Langue',
                        subtitle: 'Français',
                        onTap: () => _showComingSoon('Choix de langue'),
                      ),
                      ProfileMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Thème',
                        subtitle: 'Clair',
                        onTap: () => _showComingSoon('Thème sombre'),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Support
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Aide & Support',
                        onTap: () => _showComingSoon('Support'),
                        iconColor: AppColors.info,
                      ),
                      ProfileMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Confidentialité',
                        onTap: () =>
                            _showComingSoon('Politique de confidentialité'),
                        iconColor: AppColors.info,
                      ),
                      ProfileMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Conditions d\'utilisation',
                        onTap: () => _showComingSoon('CGU'),
                        iconColor: AppColors.info,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Déconnexion et suppression
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.logout,
                        title: 'Déconnexion',
                        onTap: _showLogoutDialog,
                        iconColor: AppColors.accent,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton suppression compte
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: _showDeleteAccountDialog,
                    child: const Text(
                      'Supprimer mon compte',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Version
                Center(
                  child: Text(
                    'Ahoe v0.6.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// En-tête du profil
  Widget _buildProfileHeader(UserModel user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Photo de profil
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: user.photoURL.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.photoURL,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildAvatarPlaceholder(user),
                        )
                      : _buildAvatarPlaceholder(user),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nom
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Badge rôle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getRoleColor(user.role).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoleIcon(user.role),
                  size: 16,
                  color: _getRoleColor(user.role),
                ),
                const SizedBox(width: 6),
                Text(
                  _getRoleLabel(user.role),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getRoleColor(user.role),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(UserModel user) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return AppColors.primary;
      case 'agent':
        return AppColors.accent;
      default:
        return AppColors.success;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'owner':
        return Icons.home_work;
      case 'agent':
        return Icons.business_center;
      default:
        return Icons.person;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'Propriétaire';
      case 'agent':
        return 'Agent';
      default:
        return 'Chercheur';
    }
  }

  /// Afficher message "Bientôt disponible"
  void _showComingSoon(String feature) {
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

  /// Dialog de déconnexion
  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }

  /// Dialog de suppression de compte
  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Supprimer le compte',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'Cette action est irréversible. Toutes vos données seront définitivement supprimées.\n\nVoulez-vous vraiment continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      // TODO: Implémenter la suppression du compte
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fonctionnalité en cours de développement'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }
}
