import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logements_app/core/constants/amenities.dart';
import 'package:logements_app/core/constants/togo_locations.dart';
import 'package:logements_app/data/models/listing_model.dart';
import 'package:logements_app/data/models/search_filter.dart';
import 'package:logements_app/presentation/providers/listing_provider.dart';
import 'package:logements_app/presentation/widgets/listing_card.dart';

/// Provider pour le filtre de recherche
final searchFilterProvider =
    StateProvider<SearchFilter>((ref) => SearchFilter());

/// Page de recherche avec filtres avancés
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _resetFilters() {
    ref.read(searchFilterProvider.notifier).state = SearchFilter();
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(searchFilterProvider);
    final listingsAsync = ref.watch(allListingsProvider);

    // Appliquer les filtres
    final filteredListings = listingsAsync.when(
      data: (listings) => _applyFilters(listings, filter),
      loading: () => <ListingModel>[],
      error: (_, __) => <ListingModel>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher'),
        actions: [
          if (!filter.isEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _resetFilters,
              tooltip: 'Réinitialiser',
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un logement...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list),
                  onPressed: _toggleFilters,
                  tooltip: 'Filtres',
                ),
              ],
            ),
          ),

          // Filtres avancés
          if (_showFilters) _buildFiltersPanel(),

          // Chips de filtres actifs
          if (!filter.isEmpty) _buildActiveFiltersChips(filter),

          // Liste des résultats
          Expanded(
            child: listingsAsync.when(
              data: (listings) {
                if (filteredListings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez d\'ajuster vos filtres',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredListings.length,
                  itemBuilder: (context, index) {
                    final listing = filteredListings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ListingCard(
                        listing: listing,
                        onTap: () => context.push('/listing/${listing.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Erreur: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    final filter = ref.watch(searchFilterProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres avancés',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Ville et quartier
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: filter.city,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Toutes')),
                    ...TogoLocations.allCities.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }),
                  ],
                  onChanged: (value) {
                    ref.read(searchFilterProvider.notifier).state =
                        filter.copyWith(city: value, neighborhood: null);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: filter.neighborhood,
                  decoration: const InputDecoration(
                    labelText: 'Quartier',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous')),
                    if (filter.city != null)
                      ...TogoLocations.getNeighborhoods(filter.city!).map((n) {
                        return DropdownMenuItem(value: n, child: Text(n));
                      }),
                  ],
                  onChanged: filter.city == null
                      ? null
                      : (value) {
                          ref.read(searchFilterProvider.notifier).state =
                              filter.copyWith(neighborhood: value);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type de logement
          DropdownButtonFormField<ListingType>(
            initialValue: filter.type,
            decoration: const InputDecoration(
              labelText: 'Type de logement',
              prefixIcon: Icon(Icons.home),
            ),
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('Tous les types')),
              ...ListingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }),
            ],
            onChanged: (value) {
              ref.read(searchFilterProvider.notifier).state =
                  filter.copyWith(type: value);
            },
          ),
          const SizedBox(height: 16),

          // Prix
          Text(
            'Prix (FCFA)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    prefixText: 'FCFA ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final price = double.tryParse(value);
                    ref.read(searchFilterProvider.notifier).state =
                        filter.copyWith(minPrice: price);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    prefixText: 'FCFA ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final price = double.tryParse(value);
                    ref.read(searchFilterProvider.notifier).state =
                        filter.copyWith(maxPrice: price);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Surface
          Text(
            'Surface (m²)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    suffixText: 'm²',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final area = double.tryParse(value);
                    ref.read(searchFilterProvider.notifier).state =
                        filter.copyWith(minArea: area);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    suffixText: 'm²',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final area = double.tryParse(value);
                    ref.read(searchFilterProvider.notifier).state =
                        filter.copyWith(maxArea: area);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chambres et salles de bain
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: filter.minBedrooms,
                  decoration: const InputDecoration(
                    labelText: 'Chambres min',
                    prefixIcon: Icon(Icons.bed),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Indifférent')),
                    ...List.generate(6, (i) => i + 1).map((n) {
                      return DropdownMenuItem(value: n, child: Text('$n+'));
                    }),
                  ],
                  onChanged: (value) {
                    ref.read(searchFilterProvider.notifier).state =
                        filter.copyWith(minBedrooms: value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: filter.minBathrooms,
                  decoration: const InputDecoration(
                    labelText: 'Salles de bain min',
                    prefixIcon: Icon(Icons.bathroom),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Indifférent')),
                    ...List.generate(4, (i) => i + 1).map((n) {
                      return DropdownMenuItem(value: n, child: Text('$n+'));
                    }),
                  ],
                  onChanged: (value) {
                    ref.read(searchFilterProvider.notifier).state =
                        filter.copyWith(minBathrooms: value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Commodités
          Text(
            'Commodités',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Amenities.all.map((amenity) {
              final isSelected =
                  filter.amenities?.contains(amenity.id) ?? false;
              return FilterChip(
                label: Text(amenity.name),
                selected: isSelected,
                onSelected: (selected) {
                  final currentAmenities =
                      List<String>.from(filter.amenities ?? []);
                  if (selected) {
                    currentAmenities.add(amenity.id);
                  } else {
                    currentAmenities.remove(amenity.id);
                  }
                  ref.read(searchFilterProvider.notifier).state =
                      filter.copyWith(amenities: currentAmenities);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips(SearchFilter filter) {
    final chips = <Widget>[];

    if (filter.city != null) {
      chips.add(_buildFilterChip('Ville: ${filter.city}', () {
        ref.read(searchFilterProvider.notifier).state =
            filter.copyWith(city: null, neighborhood: null);
      }));
    }

    if (filter.neighborhood != null) {
      chips.add(_buildFilterChip('Quartier: ${filter.neighborhood}', () {
        ref.read(searchFilterProvider.notifier).state =
            filter.copyWith(neighborhood: null);
      }));
    }

    if (filter.type != null) {
      chips.add(_buildFilterChip(filter.type!.displayName, () {
        ref.read(searchFilterProvider.notifier).state =
            filter.copyWith(type: null);
      }));
    }

    if (filter.minPrice != null || filter.maxPrice != null) {
      final priceText =
          '${filter.minPrice?.toStringAsFixed(0) ?? '0'} - ${filter.maxPrice?.toStringAsFixed(0) ?? '∞'} FCFA';
      chips.add(_buildFilterChip(priceText, () {
        ref.read(searchFilterProvider.notifier).state =
            filter.copyWith(minPrice: null, maxPrice: null);
      }));
    }

    if (filter.minBedrooms != null) {
      chips.add(_buildFilterChip('${filter.minBedrooms}+ chambres', () {
        ref.read(searchFilterProvider.notifier).state =
            filter.copyWith(minBedrooms: null);
      }));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDeleted,
    );
  }

  List<ListingModel> _applyFilters(
      List<ListingModel> listings, SearchFilter filter) {
    var filtered = listings;

    // Filtrer par recherche textuelle
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((listing) {
        return listing.title.toLowerCase().contains(query) ||
            listing.description.toLowerCase().contains(query) ||
            listing.city.toLowerCase().contains(query) ||
            listing.neighborhood.toLowerCase().contains(query);
      }).toList();
    }

    // Appliquer les filtres
    if (filter.city != null) {
      filtered = filtered.where((l) => l.city == filter.city).toList();
    }

    if (filter.neighborhood != null) {
      filtered =
          filtered.where((l) => l.neighborhood == filter.neighborhood).toList();
    }

    if (filter.type != null) {
      filtered = filtered.where((l) => l.type == filter.type).toList();
    }

    if (filter.minPrice != null) {
      filtered = filtered.where((l) => l.price >= filter.minPrice!).toList();
    }

    if (filter.maxPrice != null) {
      filtered = filtered.where((l) => l.price <= filter.maxPrice!).toList();
    }

    if (filter.minArea != null) {
      filtered = filtered.where((l) => l.area >= filter.minArea!).toList();
    }

    if (filter.maxArea != null) {
      filtered = filtered.where((l) => l.area <= filter.maxArea!).toList();
    }

    if (filter.minBedrooms != null) {
      filtered =
          filtered.where((l) => l.bedrooms >= filter.minBedrooms!).toList();
    }

    if (filter.minBathrooms != null) {
      filtered =
          filtered.where((l) => l.bathrooms >= filter.minBathrooms!).toList();
    }

    if (filter.amenities != null && filter.amenities!.isNotEmpty) {
      filtered = filtered.where((listing) {
        return filter.amenities!
            .every((amenity) => listing.amenities.contains(amenity));
      }).toList();
    }

    return filtered;
  }
}
