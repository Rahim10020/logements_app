import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logements_app/data/models/listing_model.dart';
import 'package:logements_app/data/models/search_filter.dart';
import 'package:logements_app/data/repositories/listing_repository.dart';

/// Provider du repository des annonces
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository();
});

/// Provider des annonces (liste principale)
final listingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListings();
});

/// Provider d'une annonce spécifique
final listingByIdProvider =
    StreamProvider.family<ListingModel?, String>((ref, id) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListingStream(id);
});

/// Provider des annonces d'un propriétaire
final ownerListingsProvider =
    StreamProvider.family<List<ListingModel>, String>((ref, ownerId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getOwnerListings(ownerId);
});

/// Provider du filtre de recherche
final searchFilterProvider =
    StateNotifierProvider<SearchFilterNotifier, SearchFilter>((ref) {
  return SearchFilterNotifier();
});

/// Notifier pour le filtre de recherche
class SearchFilterNotifier extends StateNotifier<SearchFilter> {
  SearchFilterNotifier() : super(SearchFilter());

  void updateFilter(SearchFilter filter) {
    state = filter;
  }

  void clearFilter() {
    state = SearchFilter();
  }

  void setCity(String? city) {
    state = state.copyWith(city: city);
  }

  void setNeighborhood(String? neighborhood) {
    state = state.copyWith(neighborhood: neighborhood);
  }

  void setType(ListingType? type) {
    state = state.copyWith(type: type);
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void setAreaRange(double? min, double? max) {
    state = state.copyWith(minArea: min, maxArea: max);
  }

  void setMinBedrooms(int? min) {
    state = state.copyWith(minBedrooms: min);
  }

  void setMinBathrooms(int? min) {
    state = state.copyWith(minBathrooms: min);
  }

  void setAmenities(List<String>? amenities) {
    state = state.copyWith(amenities: amenities);
  }
}

/// Provider des résultats de recherche
final searchResultsProvider = StreamProvider<List<ListingModel>>((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  final filter = ref.watch(searchFilterProvider);

  if (filter.isEmpty) {
    return repo.getListings();
  }

  return repo.searchListings(filter);
});

/// Controller pour les actions sur les annonces
class ListingController extends StateNotifier<AsyncValue<void>> {
  final ListingRepository _repository;

  ListingController(this._repository) : super(const AsyncValue.data(null));

  /// Crée une nouvelle annonce
  Future<String?> createListing(ListingModel listing) async {
    state = const AsyncValue.loading();

    try {
      final id = await _repository.createListing(listing);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Met à jour une annonce
  Future<void> updateListing(ListingModel listing) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateListing(listing);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Supprime une annonce
  Future<void> deleteListing(String id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteListing(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Met à jour le statut
  Future<void> updateStatus(String id, ListingStatus status) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateListingStatus(id, status);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Incrémente les vues
  Future<void> incrementViews(String id) async {
    await _repository.incrementViews(id);
  }
}

/// Provider du controller des annonces
final listingControllerProvider =
    StateNotifierProvider<ListingController, AsyncValue<void>>((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  return ListingController(repo);
});

/// Provider des villes
final citiesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getCities();
});

/// Provider des quartiers d'une ville
final neighborhoodsProvider =
    FutureProvider.family<List<String>, String>((ref, city) async {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getNeighborhoods(city);
});
