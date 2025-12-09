import 'package:flutter/foundation.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/repositories/listing_repository.dart';

/// Provider pour gérer la recherche et les filtres
class SearchProvider extends ChangeNotifier {
  final ListingRepository _listingRepository = ListingRepository();

  // État de recherche
  List<ListingModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Filtres
  String? _selectedCity;
  String? _selectedNeighborhood;
  String? _selectedPropertyType;
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;
  int? _maxBedrooms;
  int? _minBathrooms;
  double? _minArea;
  double? _maxArea;
  final Set<String> _selectedAmenities = {};

  // Tri
  String _sortBy = 'date'; // date, price_asc, price_desc, popularity

  // Getters
  List<ListingModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;
  String? get selectedNeighborhood => _selectedNeighborhood;
  String? get selectedPropertyType => _selectedPropertyType;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  int? get minBedrooms => _minBedrooms;
  int? get maxBedrooms => _maxBedrooms;
  int? get minBathrooms => _minBathrooms;
  double? get minArea => _minArea;
  double? get maxArea => _maxArea;
  Set<String> get selectedAmenities => _selectedAmenities;
  String get sortBy => _sortBy;

  /// Vérifier si des filtres sont actifs
  bool get hasActiveFilters {
    return _selectedCity != null ||
        _selectedNeighborhood != null ||
        _selectedPropertyType != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _minBedrooms != null ||
        _maxBedrooms != null ||
        _minBathrooms != null ||
        _minArea != null ||
        _maxArea != null ||
        _selectedAmenities.isNotEmpty;
  }

  /// Nombre de filtres actifs
  int get activeFiltersCount {
    int count = 0;
    if (_selectedCity != null) count++;
    if (_selectedNeighborhood != null) count++;
    if (_selectedPropertyType != null) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_minBedrooms != null || _maxBedrooms != null) count++;
    if (_minBathrooms != null) count++;
    if (_minArea != null || _maxArea != null) count++;
    if (_selectedAmenities.isNotEmpty) count++;
    return count;
  }

  /// Mettre à jour la requête de recherche
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Définir la ville
  void setCity(String? city) {
    _selectedCity = city;
    _selectedNeighborhood = null; // Reset quartier si ville change
    notifyListeners();
  }

  /// Définir le quartier
  void setNeighborhood(String? neighborhood) {
    _selectedNeighborhood = neighborhood;
    notifyListeners();
  }

  /// Définir le type de propriété
  void setPropertyType(String? type) {
    _selectedPropertyType = type;
    notifyListeners();
  }

  /// Définir la fourchette de prix
  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  /// Définir le nombre de chambres
  void setBedroomsRange(int? min, int? max) {
    _minBedrooms = min;
    _maxBedrooms = max;
    notifyListeners();
  }

  /// Définir le nombre de salles de bain
  void setMinBathrooms(int? min) {
    _minBathrooms = min;
    notifyListeners();
  }

  /// Définir la fourchette de surface
  void setAreaRange(double? min, double? max) {
    _minArea = min;
    _maxArea = max;
    notifyListeners();
  }

  /// Toggle une commodité
  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }

  /// Définir le tri
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applySorting();
    notifyListeners();
  }

  /// Rechercher avec les filtres actuels
  Future<void> search() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Recherche avec filtres de base (Firestore)
      _searchResults = await _listingRepository.searchListings(
        city: _selectedCity,
        neighborhood: _selectedNeighborhood,
        propertyType: _selectedPropertyType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minBedrooms: _minBedrooms,
        maxBedrooms: _maxBedrooms,
      );

      // Appliquer les filtres supplémentaires en mémoire
      _applyAdditionalFilters();

      // Appliquer le tri
      _applySorting();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la recherche. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appliquer les filtres supplémentaires en mémoire
  void _applyAdditionalFilters() {
    // Filtre par salles de bain
    if (_minBathrooms != null) {
      _searchResults =
          _searchResults.where((l) => l.bathrooms >= _minBathrooms!).toList();
    }

    // Filtre par surface
    if (_minArea != null) {
      _searchResults =
          _searchResults.where((l) => l.area >= _minArea!).toList();
    }
    if (_maxArea != null) {
      _searchResults =
          _searchResults.where((l) => l.area <= _maxArea!).toList();
    }

    // Filtre par commodités
    if (_selectedAmenities.isNotEmpty) {
      _searchResults = _searchResults.where((listing) {
        final amenitiesMap = listing.amenitiesMap;
        return _selectedAmenities.every((amenity) {
          return amenitiesMap[amenity] == true;
        });
      }).toList();
    }

    // Filtre par recherche textuelle (si query présente)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _searchResults = _searchResults.where((listing) {
        return listing.city.toLowerCase().contains(query) ||
            listing.neighborhood.toLowerCase().contains(query) ||
            listing.propertyType.toLowerCase().contains(query) ||
            listing.description.toLowerCase().contains(query) ||
            (listing.address?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  /// Appliquer le tri
  void _applySorting() {
    switch (_sortBy) {
      case 'price_asc':
        _searchResults.sort((a, b) => a.monthlyPrice.compareTo(b.monthlyPrice));
        break;
      case 'price_desc':
        _searchResults.sort((a, b) => b.monthlyPrice.compareTo(a.monthlyPrice));
        break;
      case 'popularity':
        _searchResults
            .sort((a, b) => b.favoritesCount.compareTo(a.favoritesCount));
        break;
      case 'area_asc':
        _searchResults.sort((a, b) => a.area.compareTo(b.area));
        break;
      case 'area_desc':
        _searchResults.sort((a, b) => b.area.compareTo(a.area));
        break;
      case 'date':
      default:
        _searchResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  /// Réinitialiser tous les filtres
  void clearFilters() {
    _selectedCity = null;
    _selectedNeighborhood = null;
    _selectedPropertyType = null;
    _minPrice = null;
    _maxPrice = null;
    _minBedrooms = null;
    _maxBedrooms = null;
    _minBathrooms = null;
    _minArea = null;
    _maxArea = null;
    _selectedAmenities.clear();
    _sortBy = 'date';
    notifyListeners();
  }

  /// Réinitialiser et rechercher
  Future<void> clearAndSearch() async {
    clearFilters();
    await search();
  }

  /// Recherche rapide (sans filtres)
  Future<void> quickSearch(String query) async {
    _searchQuery = query;
    clearFilters();
    await search();
  }
}
