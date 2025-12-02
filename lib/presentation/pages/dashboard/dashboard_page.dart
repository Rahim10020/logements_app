import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logements_app/core/constants/app_colors.dart';
import 'package:logements_app/data/models/listing_model.dart';
import 'package:logements_app/presentation/providers/listing_provider.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';

/// Page tableau de bord pour les propriétaires
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final listingsAsync = ref.watch(ownerListingsProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implémenter les notifications
            },
          ),
        ],
      ),
      body: listingsAsync.when(
        data: (listings) => _buildContent(context, ref, listings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-listing');
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une annonce'),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, List<ListingModel> listings) {
    return RefreshIndicator(
      onRefresh: () async {
        final user = ref.read(authStateProvider).value;
        ref.invalidate(ownerListingsProvider(user?.uid ?? ''));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques globales
            _buildStatsSection(listings),

            const SizedBox(height: 24),

            // Graphiques et tendances
            _buildChartsSection(context, listings),

            const SizedBox(height: 24),

            // Liste des annonces
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes annonces',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Filtrer/Trier
                    },
                    child: const Text('Tout voir'),
                  ),
                ],
              ),
            ),

            if (listings.isEmpty)
              _buildEmptyState(context)
            else
              _buildListingsSection(context, ref, listings),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<ListingModel> listings) {
    final totalViews = listings.fold<int>(0, (sum, l) => sum + l.views);
    final totalFavorites =
        listings.fold<int>(0, (sum, l) => sum + l.favoritesCount);
    final activeListings =
        listings.where((l) => l.status == ListingStatus.active).length;
    final rentedListings =
        listings.where((l) => l.status == ListingStatus.rented).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.home,
                  title: 'Actives',
                  value: '$activeListings',
                  color: AppColors.primary,
                  subtitle: '${listings.length} total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  title: 'Louées',
                  value: '$rentedListings',
                  color: AppColors.success,
                  subtitle:
                      '${rentedListings > 0 ? ((rentedListings / listings.length) * 100).toStringAsFixed(0) : '0'}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.visibility,
                  title: 'Vues totales',
                  value: _formatNumber(totalViews),
                  color: AppColors.accent,
                  subtitle:
                      '${listings.isNotEmpty ? (totalViews / listings.length).toStringAsFixed(0) : '0'} moy.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite,
                  title: 'Favoris',
                  value: _formatNumber(totalFavorites),
                  color: AppColors.error,
                  subtitle:
                      '${listings.isNotEmpty ? (totalFavorites / listings.length).toStringAsFixed(0) : '0'} moy.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(
      BuildContext context, List<ListingModel> listings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vues par annonce',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  // Simple bar chart representation
                  ...listings.take(5).map((listing) {
                    final maxViews = listings.isEmpty
                        ? 1
                        : listings
                            .map((l) => l.views)
                            .reduce((a, b) => a > b ? a : b);
                    final percentage =
                        maxViews > 0 ? (listing.views / maxViews) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  listing.title,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${listing.views}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 8,
                              backgroundColor: AppColors.grey300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsSection(
      BuildContext context, WidgetRef ref, List<ListingModel> listings) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return _buildListingItem(context, ref, listing);
      },
    );
  }

  Widget _buildListingItem(
      BuildContext context, WidgetRef ref, ListingModel listing) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.grey300,
                  child: listing.images.isNotEmpty
                      ? Image.network(
                          listing.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        )
                      : const Icon(Icons.home, size: 32),
                ),
              ),
              const SizedBox(width: 12),

              // Détails
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(listing.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(listing.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.grey600),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${listing.neighborhood}, ${listing.city}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.visibility,
                            size: 14, color: AppColors.grey600),
                        const SizedBox(width: 4),
                        Text('${listing.views}',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.favorite,
                            size: 14, color: AppColors.grey600),
                        const SizedBox(width: 4),
                        Text('${listing.favoritesCount}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu actions
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 8),
                        Text('Dupliquer'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'status',
                    child: Row(
                      children: [
                        Icon(
                          listing.status == ListingStatus.active
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          listing.status == ListingStatus.active
                              ? 'Désactiver'
                              : 'Activer',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Supprimer',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) =>
                    _handleListingAction(context, ref, listing, value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ListingStatus status) {
    Color color;
    String label;

    switch (status) {
      case ListingStatus.active:
        color = AppColors.success;
        label = 'Active';
        break;
      case ListingStatus.inactive:
        color = AppColors.grey500;
        label = 'Inactive';
        break;
      case ListingStatus.rented:
        color = AppColors.accent;
        label = 'Louée';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune annonce',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre première annonce pour commencer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-listing'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une annonce'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleListingAction(BuildContext context, WidgetRef ref,
      ListingModel listing, String action) {
    switch (action) {
      case 'edit':
        context.push('/edit-listing/${listing.id}');
        break;
      case 'duplicate':
        _duplicateListing(context, ref, listing);
        break;
      case 'status':
        _changeListingStatus(context, ref, listing);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, listing);
        break;
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, ListingModel listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer "${listing.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(listingControllerProvider.notifier)
                    .deleteListing(listing.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Annonce supprimée avec succès')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '\${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '\${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Future<void> _duplicateListing(
      BuildContext context, WidgetRef ref, ListingModel listing) async {
    try {
      final duplicatedListing = listing.copyWith(
        id: '', // Sera généré par Firebase
        title: '${listing.title} (Copie)',
        status: ListingStatus.inactive,
        views: 0,
        favoritesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      await ref
          .read(listingControllerProvider.notifier)
          .createListing(duplicatedListing);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce dupliquée avec succès')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la duplication: $e')),
        );
      }
    }
  }

  Future<void> _changeListingStatus(
      BuildContext context, WidgetRef ref, ListingModel listing) async {
    // Détermine le nouveau statut
    ListingStatus newStatus;
    if (listing.status == ListingStatus.active) {
      newStatus = ListingStatus.inactive;
    } else {
      newStatus = ListingStatus.active;
    }

    // Affiche un dialogue de confirmation pour le statut "Louée"
    if (listing.status == ListingStatus.active) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Changer le statut'),
          content: const Text('Quel statut souhaitez-vous appliquer ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'inactive'),
              child: const Text('Désactiver'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'rented'),
              child: const Text('Marquer comme louée'),
            ),
          ],
        ),
      );

      if (result == 'cancel' || result == null) return;

      if (result == 'inactive') {
        newStatus = ListingStatus.inactive;
      } else if (result == 'rented') {
        newStatus = ListingStatus.rented;
      }
    }

    try {
      await ref
          .read(listingControllerProvider.notifier)
          .updateStatus(listing.id, newStatus);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut changé: ${newStatus.displayName}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}
