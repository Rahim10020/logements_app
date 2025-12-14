import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/my_listing_card.dart';

/// Écran dashboard propriétaire
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final dashboardProvider = context.read<DashboardProvider>();

    if (authProvider.currentUser != null) {
      await dashboardProvider.fetchMyListings(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Si pas connecté, on affiche un loader (le redirect global gère la redirection vers le login)
    if (authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si connecté mais pas propriétaire -> afficher écran d'accès refusé
    if (authProvider.userModel?.role != 'owner') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Accès refusé',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Vous n\'avez pas l\'accès à cette section',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Le Dashboard est réservé aux propriétaires. Vous pouvez demander le statut propriétaire depuis votre profil.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/profile'),
                  child: const Text('Aller au profil'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mon Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
            color: AppColors.textDark,
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Chargement de vos données...',
            );
          }

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.refresh(authProvider.currentUser!.uid),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Statistiques
                _buildStatistics(dashboardProvider),
                const SizedBox(height: 24),

                // Mes annonces
                _buildMyListings(dashboardProvider),
              ],
            ),
          );
        },
      ),
      // FAB Ajouter annonce
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/add-listing'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle annonce'),
      ),
    );
  }

  /// Section statistiques
  Widget _buildStatistics(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        // Grid 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              title: 'Annonces actives',
              value: '${provider.activeListings}',
              icon: Icons.home,
              color: AppColors.success,
            ),
            StatCard(
              title: 'Annonces louées',
              value: '${provider.rentedListings}',
              icon: Icons.check_circle,
              color: AppColors.accent,
            ),
            StatCard(
              title: 'Total favoris',
              value: '${provider.totalFavorites}',
              icon: Icons.favorite,
              color: Colors.red,
            ),
            StatCard(
              title: 'Vues totales',
              value: '${provider.totalViews}',
              icon: Icons.visibility,
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  /// Section mes annonces
  Widget _buildMyListings(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mes Annonces',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${provider.totalListings} annonce${provider.totalListings > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Liste des annonces
        if (provider.myListings.isEmpty)
          EmptyState(
            icon: Icons.home_work_outlined,
            title: 'Aucune annonce',
            message: 'Vous n\'avez pas encore publié d\'annonces.\nCommencez dès maintenant !',
            buttonText: 'Créer une annonce',
            onButtonPressed: () => context.push('/dashboard/add-listing'),
          )
        else
          ...provider.myListings.map((listing) {
            return MyListingCard(
              listing: listing,
              onTap: () => context.push('/listing/${listing.id}'),
              onEdit: () => context.push('/dashboard/edit-listing/${listing.id}'),
              onDelete: () => _showDeleteDialog(listing.id),
              onToggleStatus: () => _toggleStatus(listing.id),
            );
          }),
      ],
    );
  }

  /// Dialog de confirmation de suppression
  Future<void> _showDeleteDialog(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Supprimer l\'annonce ?'),
          content: const Text(
            'Cette action est irréversible. Voulez-vous vraiment supprimer cette annonce ?',
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
      try {
        await context.read<DashboardProvider>().deleteListing(listingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Annonce supprimée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Toggle statut loué/disponible
  Future<void> _toggleStatus(String listingId) async {
    try {
      await context.read<DashboardProvider>().toggleRentedStatus(listingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut mis à jour'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

