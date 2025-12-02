import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logements_app/core/constants/app_colors.dart';
import 'package:logements_app/core/constants/app_strings.dart';
import 'package:logements_app/data/models/user_model.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';
import 'package:logements_app/presentation/widgets/custom_buttons.dart';

/// Page de sélection de rôle
class RoleSelectionPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;

  const RoleSelectionPage({
    super.key,
    required this.userData,
  });

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  UserRole? _selectedRole;

  Future<void> _handleComplete() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un rôle')),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).signUpWithEmail(
          email: widget.userData['email'] as String,
          password: widget.userData['password'] as String,
          displayName: widget.userData['name'] as String,
          role: _selectedRole!,
        );

    final authState = ref.read(authControllerProvider);
    authState.when(
      data: (_) {
        if (mounted) {
          context.go('/home');
        }
      },
      error: (error, _) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $error')),
          );
        }
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.selectRole,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'Choisissez comment vous souhaitez utiliser TogoStay',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // Rôle Locataire
              _RoleCard(
                role: UserRole.tenant,
                title: AppStrings.tenant,
                description: AppStrings.tenantDescription,
                icon: Icons.search,
                isSelected: _selectedRole == UserRole.tenant,
                onTap: isLoading
                    ? null
                    : () => setState(() => _selectedRole = UserRole.tenant),
              ),

              const SizedBox(height: 16),

              // Rôle Propriétaire
              _RoleCard(
                role: UserRole.owner,
                title: AppStrings.owner,
                description: AppStrings.ownerDescription,
                icon: Icons.home_work,
                isSelected: _selectedRole == UserRole.owner,
                onTap: isLoading
                    ? null
                    : () => setState(() => _selectedRole = UserRole.owner),
              ),

              const SizedBox(height: 16),

              // Les deux
              _RoleCard(
                role: UserRole.both,
                title: AppStrings.both,
                description: AppStrings.bothDescription,
                icon: Icons.group,
                isSelected: _selectedRole == UserRole.both,
                onTap: isLoading
                    ? null
                    : () => setState(() => _selectedRole = UserRole.both),
              ),

              const Spacer(),

              // Bouton continuer
              PrimaryButton(
                text: 'Continuer',
                onPressed: _handleComplete,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grey200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.grey600,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? AppColors.primary : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
