import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/saved_provider.dart';
import '../../home/widgets/listing_card.dart';

/// Écran des annonces favorites
class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les favoris au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final savedProvider = context.read<SavedProvider>();
      
      if (authProvider.currentUser != null) {
        savedProvider.fetchSavedListings(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Si pas connecté, rediriger vers login
    if (authProvider.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/auth/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Consumer<SavedProvider>(
          builder: (context, savedProvider, child) {
            return Row(
              children: [
                const Text(
                  'Mes Favoris',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textDark,
                  ),
                ),
                if (savedProvider.count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${savedProvider.count}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: Consumer<SavedProvider>(
        builder: (context, savedProvider, child) {
          if (savedProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Chargement de vos favoris...',
            );
          }

          if (savedProvider.savedListings.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'Aucun favori',
              message: 'Vous n\'avez pas encore ajouté d\'annonces à vos favoris.',
              buttonText: 'Découvrir des annonces',
              onButtonPressed: () => context.go('/'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: savedProvider.savedListings.length,
            itemBuilder: (context, index) {
              final listing = savedProvider.savedListings[index];

              return Dismissible(
                key: Key(listing.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text('Retirer des favoris ?'),
                        content: const Text(
                          'Voulez-vous vraiment retirer cette annonce de vos favoris ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Retirer'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _removeFavorite(listing.id);
                },
                child: ListingCard(
                  listing: listing,
                  isFavorite: true,
                  onTap: () => context.push('/listing/${listing.id}'),
                  onFavorite: () => _removeFavorite(listing.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Retirer des favoris
  Future<void> _removeFavorite(String listingId) async {
    final authProvider = context.read<AuthProvider>();
    final savedProvider = context.read<SavedProvider>();

    try {
      await savedProvider.removeFromSaved(
        authProvider.currentUser!.uid,
        listingId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retiré des favoris'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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

