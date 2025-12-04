import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:logements_app/core/constants/amenities.dart';
import 'package:logements_app/core/constants/app_colors.dart';
import 'package:logements_app/data/models/listing_model.dart';
import 'package:logements_app/presentation/providers/listing_provider.dart';
import 'package:logements_app/presentation/providers/favorite_provider.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';

/// Page de détail d'une annonce
class ListingDetailPage extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailPage({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends ConsumerState<ListingDetailPage> {
  int _currentImageIndex = 0;
  final _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingByIdProvider(widget.listingId));

    return Scaffold(
      body: listingAsync.when(
        data: (listing) => listing != null
            ? _buildContent(listing)
            : const Center(child: Text('Annonce non trouvée')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ListingModel listing) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    final isFavorite = ref.watch(isFavoriteProvider(listing.id));

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // AppBar avec image carousel
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageCarousel(listing),
              ),
              actions: [
                // Bouton favori
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.white,
                  ),
                  onPressed: () {
                    ref
                        .read(favoriteControllerProvider.notifier)
                        .toggleFavorite(listing.id);
                  },
                ),
                // Bouton partage
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareListing(listing),
                ),
              ],
            ),

            // Contenu
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations principales
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prix
                        Text(
                          currencyFormat.format(listing.price),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // Titre
                        Text(
                          listing.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),

                        // Localisation
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 20, color: AppColors.grey600),
                            const SizedBox(width: 4),
                            Text(
                              '${listing.neighborhood}, ${listing.city}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.grey600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Caractéristiques
                        Row(
                          children: [
                            _buildFeature(
                                Icons.square_foot, '${listing.area} m²'),
                            const SizedBox(width: 16),
                            _buildFeature(Icons.bed, '${listing.bedrooms} ch.'),
                            const SizedBox(width: 16),
                            _buildFeature(
                                Icons.bathroom, '${listing.bathrooms} sdb'),
                            const SizedBox(width: 16),
                            _buildFeature(Icons.home, listing.type.displayName),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Description
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listing.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Commodités
                  if (listing.amenities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commodités',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: listing.amenities.map((amenityId) {
                              final amenity = Amenities.getById(amenityId);
                              if (amenity == null) {
                                return const SizedBox.shrink();
                              }
                              return _buildAmenityChip(
                                  amenity.name, amenity.icon);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  const Divider(),

                  // Carte
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Localisation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listing.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildMap(listing.location),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.directions),
                          label: const Text('Obtenir l\'itinéraire'),
                          onPressed: () => _openMaps(listing.location),
                        ),
                      ],
                    ),
                  ),

                  // Statistiques
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildStat(
                            Icons.visibility, '${listing.views}', 'Vues'),
                        const SizedBox(width: 24),
                        _buildStat(Icons.favorite, '${listing.favoritesCount}',
                            'Favoris'),
                        const SizedBox(width: 24),
                        _buildStat(
                          Icons.calendar_today,
                          _formatDate(listing.createdAt),
                          'Publié',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Espace pour le bouton flottant
                ],
              ),
            ),
          ],
        ),
        _buildBottomBar(listing),
      ],
    );
  }

  Widget _buildImageCarousel(ListingModel listing) {
    if (listing.images.isEmpty) {
      return Container(
        color: AppColors.grey300,
        child: const Center(
          child: Icon(Icons.image_not_supported,
              size: 64, color: AppColors.grey600),
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            enableInfiniteScroll: listing.images.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: listing.images.map((imageUrl) {
            return CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: AppColors.grey300,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.grey300,
                child: const Icon(Icons.error, size: 64),
              ),
            );
          }).toList(),
        ),
        if (listing.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentImageIndex,
                count: listing.images.length,
                effect: const WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppColors.white,
                  dotColor: AppColors.grey400,
                ),
                onDotClicked: (index) {
                  _carouselController.animateToPage(index);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMap(LatLng location) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: location,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.togostay.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: location,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_pin,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey600),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAmenityChip(String label, String iconName) {
    return Chip(
      avatar: Icon(
        _getIconData(iconName),
        size: 18,
        color: AppColors.primary,
      ),
      label: Text(label),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.grey600),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBottomBar(ListingModel listing) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Appeler'),
                  onPressed: () => _callOwner(listing),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                  onPressed: () => _messageOwner(listing),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Mapping des noms d'icônes aux IconData
    final iconMap = {
      'wifi': Icons.wifi,
      'local_parking': Icons.local_parking,
      'ac_unit': Icons.ac_unit,
      'pool': Icons.pool,
      'yard': Icons.yard,
      'security': Icons.security,
      'weekend': Icons.weekend,
      'kitchen': Icons.kitchen,
      'local_laundry_service': Icons.local_laundry_service,
      'tv': Icons.tv,
      'balcony': Icons.balcony,
      'deck': Icons.deck,
      'elevator': Icons.elevator,
      'power': Icons.power,
      'hot_tub': Icons.hot_tub,
      'microwave': Icons.microwave,
      'fitness_center': Icons.fitness_center,
      'playground': Icons.play_circle,
      'pets': Icons.pets,
    };
    return iconMap[iconName] ?? Icons.check_circle;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Future<void> _shareListing(ListingModel listing) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '${listing.title}\n'
            '${listing.price} FCFA/mois\n'
            '${listing.neighborhood}, ${listing.city}\n'
            '\n'
            'Voir sur TogoStay: https://togostay.com/listing/${listing.id}',
        subject: listing.title,
      ),
    );
  }

  Future<void> _openMaps(LatLng location) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callOwner(ListingModel listing) async {
    // Récupère le profil du propriétaire
    final ownerProfile =
        await ref.read(authRepositoryProvider).getUserProfile(listing.ownerId);

    if (ownerProfile?.phoneNumber == null ||
        ownerProfile!.phoneNumber!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro de téléphone non disponible'),
          ),
        );
      }
      return;
    }

    final phone = ownerProfile.phoneNumber!;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir l\'application téléphone'),
          ),
        );
      }
    }
  }

  Future<void> _messageOwner(ListingModel listing) async {
    // Récupère le profil du propriétaire
    final ownerProfile =
        await ref.read(authRepositoryProvider).getUserProfile(listing.ownerId);

    if (ownerProfile?.phoneNumber == null ||
        ownerProfile!.phoneNumber!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro de téléphone non disponible'),
          ),
        );
      }
      return;
    }

    final phone = ownerProfile.phoneNumber!.replaceAll(RegExp(r'[^0-9+]'), '');
    final message = Uri.encodeComponent(
      'Bonjour, je suis intéressé(e) par votre annonce "${listing.title}" à ${listing.price} FCFA/mois.',
    );

    // Essayer d'ouvrir WhatsApp
    final whatsappUrl = Uri.parse('https://wa.me/$phone?text=$message');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: ouvrir l'application SMS
      final smsUrl = Uri.parse('sms:$phone?body=$message');
      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir la messagerie'),
            ),
          );
        }
      }
    }
  }
}
