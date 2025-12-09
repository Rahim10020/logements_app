import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/listing_model.dart';

/// Widget de carte d'annonce pour le dashboard propriétaire
class MyListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const MyListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'fr_FR');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge statut
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: listing.imageIds.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: listing.imageIds.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.home_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.home_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                // Badge statut
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: listing.isRented
                          ? AppColors.accent
                          : AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      listing.isRented ? 'LOUÉ' : 'DISPONIBLE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Informations
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type et localisation
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.propertyType,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${listing.neighborhood}, ${listing.city}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Prix
                  Text(
                    '${formatter.format(listing.monthlyPrice.toInt())} FCFA/mois',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Caractéristiques
                  Row(
                    children: [
                      _buildFeature(Icons.bed_outlined, '${listing.bedrooms}'),
                      const SizedBox(width: 16),
                      _buildFeature(Icons.bathtub_outlined, '${listing.bathrooms}'),
                      const SizedBox(width: 16),
                      _buildFeature(Icons.square_foot_outlined, '${listing.area.toInt()}m²'),
                      const Spacer(),
                      _buildFeature(Icons.favorite, '${listing.favoritesCount}'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      // Toggle statut
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onToggleStatus,
                          icon: Icon(
                            listing.isRented ? Icons.check_circle : Icons.cancel,
                            size: 18,
                          ),
                          label: Text(
                            listing.isRented ? 'Marquer dispo' : 'Marquer loué',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Éditer
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Supprimer
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          foregroundColor: Colors.red,
                        ),
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

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

