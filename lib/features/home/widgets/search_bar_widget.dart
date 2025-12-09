import 'package:flutter/material.dart';

/// Widget de barre de recherche pour l'écran d'accueil
class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String placeholder;

  const SearchBarWidget({
    super.key,
    required this.onTap,
    this.placeholder = 'Rechercher une ville, quartier...',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              placeholder,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
