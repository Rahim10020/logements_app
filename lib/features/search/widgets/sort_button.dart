import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget de bouton de tri avec menu déroulant
class SortButton extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortChanged;

  const SortButton({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'date':
        return 'Plus récent';
      case 'price_asc':
        return 'Prix croissant';
      case 'price_desc':
        return 'Prix décroissant';
      case 'popularity':
        return 'Popularité';
      case 'area_asc':
        return 'Surface croissante';
      case 'area_desc':
        return 'Surface décroissante';
      default:
        return 'Trier';
    }
  }

  IconData _getSortIcon(String sort) {
    switch (sort) {
      case 'price_asc':
        return Icons.arrow_upward;
      case 'price_desc':
        return Icons.arrow_downward;
      case 'popularity':
        return Icons.favorite;
      case 'area_asc':
        return Icons.arrow_upward;
      case 'area_desc':
        return Icons.arrow_downward;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSortChanged,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSortIcon(currentSort),
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _getSortLabel(currentSort),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem('date', 'Plus récent', Icons.schedule),
        _buildMenuItem('price_asc', 'Prix croissant', Icons.arrow_upward),
        _buildMenuItem('price_desc', 'Prix décroissant', Icons.arrow_downward),
        _buildMenuItem('popularity', 'Popularité', Icons.favorite),
        _buildMenuItem('area_asc', 'Surface croissante', Icons.arrow_upward),
        _buildMenuItem('area_desc', 'Surface décroissante', Icons.arrow_downward),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: currentSort == value ? AppColors.primary : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: currentSort == value ? AppColors.primary : AppColors.textDark,
              fontWeight: currentSort == value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (currentSort == value) ...[
            const Spacer(),
            const Icon(
              Icons.check,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }
}

