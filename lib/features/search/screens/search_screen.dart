import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/cities_data.dart';
import '../providers/search_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../saved/providers/saved_provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../home/widgets/listing_card.dart';
import '../widgets/sort_button.dart';
import '../widgets/price_range_selector.dart';
import '../widgets/number_selector.dart';

/// Écran de recherche avec filtres
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Lancer une recherche initiale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().search();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          color: AppColors.textDark,
        ),
        title: const Text(
          'Rechercher',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          // Bouton reset
          Consumer<SearchProvider>(
            builder: (context, searchProvider, child) {
              if (!searchProvider.hasActiveFilters) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _searchController.clear();
                  searchProvider.clearAndSearch();
                },
                tooltip: 'Réinitialiser',
                color: AppColors.textDark,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(),

          // Filtres et tri
          _buildFiltersRow(),

          // Résultats
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return const LoadingIndicator(
                    message: 'Recherche en cours...',
                  );
                }

                if (searchProvider.searchResults.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'Aucun résultat',
                    message: 'Essayez de modifier vos critères de recherche.',
                    buttonText: 'Réinitialiser',
                    onButtonPressed: () {
                      _searchController.clear();
                      searchProvider.clearAndSearch();
                    },
                  );
                }

                return Column(
                  children: [
                    // En-tête résultats
                    _buildResultsHeader(searchProvider.searchResults.length),

                    // Grid de résultats
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: searchProvider.searchResults.length,
                        itemBuilder: (context, index) {
                          final listing = searchProvider.searchResults[index];
                          return Consumer<SavedProvider>(
                            builder: (context, savedProvider, child) {
                              return ListingCard(
                                listing: listing,
                                isFavorite: savedProvider.isSaved(listing.id),
                                onTap: () => context.push('/listing/${listing.id}'),
                                onFavorite: () => _toggleFavorite(listing.id),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // Bouton filtres flottant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFiltersBottomSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.tune),
        label: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) {
            final count = searchProvider.activeFiltersCount;
            return Text(count > 0 ? 'Filtres ($count)' : 'Filtres');
          },
        ),
      ),
    );
  }

  /// Barre de recherche
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: 'Ville, quartier, type de bien...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchProvider>().setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onSubmitted: (value) {
          context.read<SearchProvider>().quickSearch(value);
        },
        onChanged: (value) {
          context.read<SearchProvider>().setSearchQuery(value);
        },
      ),
    );
  }

  /// Ligne de filtres rapides et tri
  Widget _buildFiltersRow() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Filtres rapides villes
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: TogoLocations.cities.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final city = TogoLocations.cities[index];
                      final isSelected = searchProvider.selectedCity == city;
                      return FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (selected) {
                          searchProvider.setCity(selected ? city : null);
                          searchProvider.search();
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.grey[300]!,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bouton tri
              SortButton(
                currentSort: searchProvider.sortBy,
                onSortChanged: (sort) {
                  searchProvider.setSortBy(sort);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// En-tête des résultats
  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Text(
            '$count résultat${count > 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Afficher la bottom sheet des filtres
  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FiltersBottomSheet(),
    );
  }

  /// Toggle favori
  Future<void> _toggleFavorite(String listingId) async {
    final authProvider = context.read<AuthProvider>();
    final savedProvider = context.read<SavedProvider>();

    if (authProvider.currentUser == null) {
      context.push('/auth/login');
      return;
    }

    try {
      await savedProvider.toggleSaved(
        authProvider.currentUser!.uid,
        listingId,
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
}

/// Bottom sheet des filtres avancés
class FiltersBottomSheet extends StatefulWidget {
  const FiltersBottomSheet({super.key});

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<SearchProvider>(
            builder: (context, searchProvider, child) {
              return Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // En-tête
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtres',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (searchProvider.hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              searchProvider.clearFilters();
                            },
                            child: const Text('Réinitialiser'),
                          ),
                      ],
                    ),
                  ),

                  // Contenu scrollable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Type de propriété
                        _buildPropertyTypeFilter(searchProvider),
                        const SizedBox(height: 24),

                        // Prix
                        _buildPriceFilter(searchProvider),
                        const SizedBox(height: 24),

                        // Chambres
                        _buildBedroomsFilter(searchProvider),
                        const SizedBox(height: 24),

                        // Salles de bain
                        _buildBathroomsFilter(searchProvider),
                        const SizedBox(height: 24),

                        // Surface
                        _buildAreaFilter(searchProvider),
                        const SizedBox(height: 24),

                        // Commodités
                        _buildAmenitiesFilter(searchProvider),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),

                  // Bouton appliquer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          searchProvider.search();
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Afficher les résultats (${searchProvider.searchResults.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Widgets de filtres individuels seront ajoutés dans la prochaine partie...
  Widget _buildPropertyTypeFilter(SearchProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de bien',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TogoLocations.propertyTypes.map((type) {
            final isSelected = provider.selectedPropertyType == type;
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                provider.setPropertyType(selected ? type : null);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter(SearchProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prix mensuel (FCFA)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        PriceRangeSelector(
          minPrice: provider.minPrice,
          maxPrice: provider.maxPrice,
          onChanged: (min, max) {
            provider.setPriceRange(min, max);
          },
          min: 20000,
          max: 1000000,
        ),
      ],
    );
  }

  Widget _buildBedroomsFilter(SearchProvider provider) {
    return NumberSelector(
      label: 'Chambres',
      minValue: provider.minBedrooms,
      maxValue: provider.maxBedrooms,
      onChanged: (min, max) {
        provider.setBedroomsRange(min, max);
      },
      min: 0,
      max: 10,
      showRange: true,
    );
  }

  Widget _buildBathroomsFilter(SearchProvider provider) {
    return NumberSelector(
      label: 'Salles de bain (minimum)',
      minValue: provider.minBathrooms,
      maxValue: null,
      onChanged: (min, _) {
        provider.setMinBathrooms(min);
      },
      min: 0,
      max: 5,
      showRange: false,
    );
  }

  Widget _buildAreaFilter(SearchProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Surface (m²)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minimum',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Min m²',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final num = double.tryParse(value);
                      provider.setAreaRange(num, provider.maxArea);
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Text('—', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maximum',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Max m²',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final num = double.tryParse(value);
                      provider.setAreaRange(provider.minArea, num);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesFilter(SearchProvider provider) {
    final amenities = [
      'Meublé',
      'Climatisation',
      'WiFi',
      'Parking',
      'Cuisine équipée',
      'Balcon',
      'Générateur',
      'Château d\'eau',
      'Sécurité',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commodités',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            final isSelected = provider.selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (selected) {
                provider.toggleAmenity(amenity);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

