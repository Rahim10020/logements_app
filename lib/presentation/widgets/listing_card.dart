import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logements_app/core/constants/app_colors.dart';
import 'package:logements_app/core/constants/app_dimensions.dart';
import 'package:logements_app/core/utils/format_utils.dart';
import 'package:logements_app/data/models/listing_model.dart';
import 'package:logements_app/presentation/providers/favorite_provider.dart';

/// Carte d'annonce pour la grille
class ListingCard extends ConsumerWidget {
  final ListingModel listing;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(listing.id));

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: listing.images.isNotEmpty
                      ? listing.images.first
                      : 'https://via.placeholder.com/400x300',
                  height: AppDimensions.listingCardImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey200,
                    child: const Icon(Icons.error),
                  ),
                ),

                // Bouton favoris
                Positioned(
                  top: AppDimensions.spacing8,
                  right: AppDimensions.spacing8,
                  child: IconButton(
                    onPressed: () {
                      ref
                          .read(favoriteControllerProvider.notifier)
                          .toggleFavorite(listing.id);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.brand : AppColors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                // Badge type
                Positioned(
                  bottom: AppDimensions.spacing8,
                  left: AppDimensions.spacing8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing12,
                      vertical: AppDimensions.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                    child: Text(
                      listing.type.displayName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Infos
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppDimensions.spacing4),

                  // Localisation
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: AppDimensions.iconSmall,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Expanded(
                        child: Text(
                          '${listing.neighborhood}, ${listing.city}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacing8),

                  // Prix et specs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FormatUtils.formatPrice(listing.price),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.brand,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Row(
                        children: [
                          _buildSpec(Icons.bed, listing.bedrooms.toString()),
                          const SizedBox(width: AppDimensions.spacing8),
                          _buildSpec(
                              Icons.shower, listing.bathrooms.toString()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpec(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSmall, color: AppColors.grey500),
        const SizedBox(width: AppDimensions.spacing4),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
