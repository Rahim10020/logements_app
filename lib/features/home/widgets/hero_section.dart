import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget de section hero pour l'écran d'accueil
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal
          Text(
            'Trouvez votre chez-vous au Togo',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 8),
          // Sous-titre
          Text(
            'Des milliers de logements disponibles',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}

