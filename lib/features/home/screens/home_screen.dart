import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/cities_data.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../saved/providers/saved_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/hero_section.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/neighborhood_section.dart';
import '../widgets/listing_card.dart';

/// Écran d'accueil avec liste des annonces
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      homeProvider.fetchListings();

      // Charger les IDs des favoris de l'utilisateur
      final authProvider = context.read<AuthProvider>();
      final savedProvider = context.read<SavedProvider>();
      if (authProvider.currentUser != null) {
        savedProvider.loadSavedIds(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Chargement des annonces...',
            );
          }

          if (homeProvider.errorMessage != null) {
            return CustomErrorWidget(
              message: homeProvider.errorMessage!,
              onRetry: () => homeProvider.fetchListings(),
            );
          }

          if (homeProvider.listings.isEmpty) {
            return const CustomErrorWidget(
              message: 'Aucune annonce disponible pour le moment.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => homeProvider.refreshListings(),
            color: AppColors.primary,
            child: ListView(
              children: [
                // Section Hero
                const HeroSection(),

                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchBarWidget(
                    onTap: () => context.push('/search'),
                  ),
                ),

                const SizedBox(height: 24),

                // Filtres rapides
                _buildQuickFilters(homeProvider),

                const SizedBox(height: 24),

                // Annonces par quartier
                ...homeProvider.listingsByNeighborhood.entries.map(
                  (entry) {
                    return NeighborhoodSection(
                      neighborhood: entry.key,
                      count: entry.value.length,
                      listings: entry.value.map((listing) {
                        return Consumer<SavedProvider>(
                          builder: (context, savedProvider, child) {
                            return ListingCard(
                              listing: listing,
                              isFavorite: savedProvider.isSaved(listing.id),
                              onTap: () =>
                                  context.push('/listing/${listing.id}'),
                              onFavorite: () => _toggleFavorite(listing.id),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// AppBar personnalisée
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Ahoe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      actions: [
        // Bouton favoris avec badge
        Consumer<SavedProvider>(
          builder: (context, savedProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () => context.push('/saved'),
                  color: AppColors.textDark,
                ),
                if (savedProvider.count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        savedProvider.count > 9
                            ? '9+'
                            : '${savedProvider.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Filtres rapides (chips scrollables)
  Widget _buildQuickFilters(HomeProvider homeProvider) {
    final filters = ['Tous', ...TogoLocations.propertyTypes.take(5)];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = homeProvider.selectedFilter == filter;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              homeProvider.applyFilter(filter);
            },
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Toggle favori
  Future<void> _toggleFavorite(String listingId) async {
    final authProvider = context.read<AuthProvider>();
    final savedProvider = context.read<SavedProvider>();

    if (authProvider.currentUser == null) {
      // Rediriger vers login
      if (mounted) {
        context.push('/auth/login');
      }
      return;
    }

    try {
      await savedProvider.toggleSaved(
        authProvider.currentUser!.uid,
        listingId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
