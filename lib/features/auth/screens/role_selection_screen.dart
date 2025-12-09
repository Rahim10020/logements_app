import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

/// Écran de sélection du rôle utilisateur
/// 3 options: Locataire, Propriétaire, ou Les deux
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  Future<void> _handleContinue() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un rôle'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateUserRole(_selectedRole!);

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erreur lors de la mise à jour',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Titre et description
              const Text(
                'Comment souhaitez-vous\nutiliser Ahoe ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sélectionnez votre profil pour personnaliser votre expérience',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Cartes de sélection
              Expanded(
                child: Column(
                  children: [
                    _RoleCard(
                      icon: Icons.search_rounded,
                      title: 'Je cherche un logement',
                      description: 'Parcourez et trouvez votre logement idéal',
                      role: 'tenant',
                      isSelected: _selectedRole == 'tenant',
                      onTap: () {
                        setState(() {
                          _selectedRole = 'tenant';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      icon: Icons.home_rounded,
                      title: 'Je loue des biens',
                      description: 'Publiez vos annonces et gérez vos biens',
                      role: 'owner',
                      isSelected: _selectedRole == 'owner',
                      onTap: () {
                        setState(() {
                          _selectedRole = 'owner';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Les deux',
                      description: 'Cherchez et louez des logements',
                      role: 'both',
                      isSelected: _selectedRole == 'both',
                      onTap: () {
                        setState(() {
                          _selectedRole = 'both';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton Continuer
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return AuthButton(
                    text: 'Continuer',
                    onPressed: _handleContinue,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de carte pour la sélection de rôle
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? AppColors.primary : AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Indicateur de sélection
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
