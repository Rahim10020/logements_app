import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget grille de commodités
class AmenitiesGrid extends StatelessWidget {
  final Map<String, bool> amenities;

  const AmenitiesGrid({
    super.key,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrer uniquement les commodités actives
    final activeAmenities =
        amenities.entries.where((entry) => entry.value).toList();

    if (activeAmenities.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'Commodités',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
            ),
            itemCount: activeAmenities.length,
            itemBuilder: (context, index) {
              final amenity = activeAmenities[index];
              return _buildAmenityItem(amenity.key);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityItem(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForAmenity(label),
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Icône appropriée pour chaque commodité
  IconData _getIconForAmenity(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'meublé':
        return Icons.weekend_outlined;
      case 'climatisation':
        return Icons.ac_unit;
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case 'cuisine équipée':
        return Icons.kitchen;
      case 'balcon':
        return Icons.balcony;
      case 'générateur':
        return Icons.power;
      case 'château d\'eau':
        return Icons.water_drop;
      case 'forage':
        return Icons.water;
      case 'sécurité':
        return Icons.security;
      case 'clôturé':
        return Icons.fence;
      case 'sol carrelé':
        return Icons.grid_on;
      case 'ventilateur':
        return Icons.air;
      case 'compteur électrique individuel':
        return Icons.electrical_services;
      case 'compteur d\'eau individuel':
        return Icons.water_damage;
      default:
        return Icons.check_circle_outline;
    }
  }
}
