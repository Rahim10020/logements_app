import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logements_app/core/constants/app_colors.dart';
import 'package:logements_app/core/constants/app_dimensions.dart';
import 'package:logements_app/core/constants/app_strings.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';
import 'package:logements_app/presentation/providers/listing_provider.dart';
import 'package:logements_app/presentation/providers/favorite_provider.dart';
import 'package:logements_app/presentation/widgets/listing_card.dart';

/// Page des favoris
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentFirebaseUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.favorites),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 64,
                color: AppColors.grey400,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                'Connectez-vous pour voir vos favoris',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    final favoritesAsync = ref.watch(userFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.favorites),
      ),
      body: favoritesAsync.when(
        data: (favoriteIds) {
          if (favoriteIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Text(
                    'Aucun favori pour le moment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    'Ajoutez des annonces à vos favoris',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final listingsAsync = ref.watch(listingsProvider);

          return listingsAsync.when(
            data: (allListings) {
              final favoriteListings = allListings
                  .where((listing) => favoriteIds.contains(listing.id))
                  .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(listingsProvider);
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppDimensions.spacing12,
                    mainAxisSpacing: AppDimensions.spacing12,
                  ),
                  itemCount: favoriteListings.length,
                  itemBuilder: (context, index) {
                    final listing = favoriteListings[index];
                    return ListingCard(
                      listing: listing,
                      onTap: () => context.push('/listing/${listing.id}'),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Erreur: $error'),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}
