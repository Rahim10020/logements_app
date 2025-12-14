import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/listing_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../saved/providers/saved_provider.dart';
import '../providers/listing_detail_provider.dart';
import '../widgets/image_carousel.dart';
import '../widgets/amenities_grid.dart';
import '../widgets/map_widget.dart';
import '../widgets/owner_card.dart';

/// Écran de détails d'une annonce
class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final UserRepository _userRepository = UserRepository();
  UserModel? _owner;
  bool _isLoadingOwner = true;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final detailProvider = context.read<ListingDetailProvider>();
    final authProvider = context.read<AuthProvider>();
    final savedProvider = context.read<SavedProvider>();
    await detailProvider.fetchListingById(widget.listingId);

    // Charger les infos du propriétaire
    if (detailProvider.listing != null) {
      try {
        _owner =
            await _userRepository.getUserById(detailProvider.listing!.userId);
      } catch (e) {
        debugPrint('Erreur chargement propriétaire: $e');
      }
      if (mounted) {
        setState(() {
          _isLoadingOwner = false;
        });
      }
    }

    // Charger les favoris de l'utilisateur
    if (authProvider.currentUser != null) {
      savedProvider.loadSavedIds(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ListingDetailProvider>(
        builder: (context, detailProvider, child) {
          if (detailProvider.isLoading) {
            return const LoadingIndicator(
              message: 'Chargement de l\'annonce...',
            );
          }

          if (detailProvider.listing == null) {
            return CustomErrorWidget(
              message: 'Cette annonce n\'existe pas ou a été supprimée.',
              onRetry: () => detailProvider.fetchListingById(widget.listingId),
            );
          }

          final listing = detailProvider.listing!;
          final formatter = NumberFormat('#,###', 'fr_FR');

          return CustomScrollView(
            slivers: [
              // AppBar transparente avec actions
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => context.pop(),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ),
                actions: [
                  // Bouton partage
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => _shareListing(listing),
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.share),
                        ),
                      ),
                    ),
                  ),
                  // Bouton favori
                  Consumer<SavedProvider>(
                    builder: (context, savedProvider, child) {
                      final isFavorite = savedProvider.isSaved(listing.id);
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () => _toggleFavorite(),
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ImageCarousel(
                    imageUrls: listing.imageIds,
                    onViewAll: () {
                      // TODO: Ouvrir galerie complète
                    },
                  ),
                ),
              ),
              // Contenu
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  // Informations principales
                  _buildMainInfo(listing, formatter),
                  const SizedBox(height: 20),
                  // Description
                  _buildDescription(listing),
                  const SizedBox(height: 20),
                  // Commodités
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AmenitiesGrid(amenities: listing.amenitiesMap),
                  ),
                  const SizedBox(height: 20),
                  // Carte
                  if (listing.latitude != null && listing.longitude != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Localisation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          MapWidget(
                            latitude: listing.latitude,
                            longitude: listing.longitude,
                            address: listing.address,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Propriétaire
                  if (_owner != null && !_isLoadingOwner)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OwnerCard(owner: _owner!),
                    ),
                  const SizedBox(height: 100), // Espace pour le FAB
                ]),
              ),
            ],
          );
        },
      ),
      // FAB pour contact rapide
      floatingActionButton: Consumer<ListingDetailProvider>(
        builder: (context, detailProvider, child) {
          if (detailProvider.listing == null || _owner == null) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () => _showContactOptions(),
            backgroundColor: AppColors.primary,
            label: const Text('Contacter'),
            icon: const Icon(Icons.chat_bubble_outline),
          );
        },
      ),
    );
  }

  /// Section informations principales
  Widget _buildMainInfo(ListingModel listing, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type de bien
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              listing.propertyType,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Prix
          Text(
            '${formatter.format(listing.monthlyPrice.toInt())} FCFA',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            'par mois • ${formatter.format(listing.pricePerSquareMeter.toInt())} FCFA/m²',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Caractéristiques
          Row(
            children: [
              _buildFeature(Icons.bed_outlined, '${listing.bedrooms} chambres'),
              const SizedBox(width: 20),
              _buildFeature(Icons.bathtub_outlined, '${listing.bathrooms} SDB'),
              const SizedBox(width: 20),
              _buildFeature(
                  Icons.square_foot_outlined, '${listing.area.toInt()} m²'),
            ],
          ),
          const SizedBox(height: 16),
          // Adresse
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${listing.neighborhood}, ${listing.city}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (listing.address != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                listing.address!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget caractéristique
  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Section description
  Widget _buildDescription(ListingModel listing) {
    if (listing.description.isEmpty) {
      return const SizedBox.shrink();
    }

    final shouldShowExpand = listing.description.length > 200;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            listing.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          if (shouldShowExpand) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded ? 'Voir moins' : 'Voir plus',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Partager l'annonce
  void _shareListing(ListingModel listing) {
    final text = '''
${listing.propertyType} à louer - ${listing.neighborhood}, ${listing.city}

💰 ${NumberFormat('#,###', 'fr_FR').format(listing.monthlyPrice.toInt())} FCFA/mois
🛏️ ${listing.bedrooms} chambres
🚿 ${listing.bathrooms} salles de bain
📐 ${listing.area.toInt()} m²

${listing.description.isNotEmpty ? listing.description : ''}

Via Ahoe
''';
    SharePlus.instance.share(ShareParams(text: text, subject: 'Annonce Ahoe'));
  }

  /// Toggle favori
  Future<void> _toggleFavorite() async {
    final authProvider = context.read<AuthProvider>();
    final savedProvider = context.read<SavedProvider>();

    if (authProvider.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connectez-vous pour ajouter aux favoris'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await savedProvider.toggleSaved(
        authProvider.currentUser!.uid,
        widget.listingId,
      );
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

  /// Afficher options de contact
  void _showContactOptions() {
    // Implémentation similaire à OwnerCard
    if (_owner != null) {
      // Utiliser le widget OwnerCard pour cohérence
    }
  }
}
