import 'package:flutter/foundation.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/repositories/listing_repository.dart';

/// Provider pour gérer l'écran d'accueil et les annonces
class HomeProvider extends ChangeNotifier {
  final ListingRepository _listingRepository = ListingRepository();

  // État
  List<ListingModel> _listings = [];
  Map<String, List<ListingModel>> _listingsByNeighborhood = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'Tous';

  // Getters
  List<ListingModel> get listings => _listings;
  Map<String, List<ListingModel>> get listingsByNeighborhood => _listingsByNeighborhood;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  /// Récupérer toutes les annonces
  Future<void> fetchListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listings = await _listingRepository.getAllListings();
      groupListingsByNeighborhood();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger les annonces. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchir les annonces (pull-to-refresh)
  Future<void> refreshListings() async {
    try {
      _listings = await _listingRepository.getAllListings();
      groupListingsByNeighborhood();
      applyFilter(_selectedFilter);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de rafraîchir les annonces.';
      notifyListeners();
    }
  }

  /// Grouper les annonces par quartier
  void groupListingsByNeighborhood() {
    _listingsByNeighborhood.clear();

    for (var listing in _listings) {
      if (!_listingsByNeighborhood.containsKey(listing.neighborhood)) {
        _listingsByNeighborhood[listing.neighborhood] = [];
      }
      _listingsByNeighborhood[listing.neighborhood]!.add(listing);
    }

    notifyListeners();
  }

  /// Appliquer un filtre sur les types de propriété
  void applyFilter(String filter) {
    _selectedFilter = filter;

    if (filter == 'Tous') {
      groupListingsByNeighborhood();
    } else {
      _listingsByNeighborhood.clear();
      final filteredListings = _listings
          .where((listing) => listing.propertyType == filter)
          .toList();

      for (var listing in filteredListings) {
        if (!_listingsByNeighborhood.containsKey(listing.neighborhood)) {
          _listingsByNeighborhood[listing.neighborhood] = [];
        }
        _listingsByNeighborhood[listing.neighborhood]!.add(listing);
      }
    }

    notifyListeners();
  }

  /// Récupérer les annonces d'une ville spécifique
  Future<void> fetchListingsByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listings = await _listingRepository.getListingsByCity(city);
      groupListingsByNeighborhood();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger les annonces de cette ville.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir le nombre total d'annonces par quartier
  int getNeighborhoodCount(String neighborhood) {
    return _listingsByNeighborhood[neighborhood]?.length ?? 0;
  }
}

