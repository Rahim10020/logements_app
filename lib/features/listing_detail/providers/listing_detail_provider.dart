import 'package:flutter/foundation.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/repositories/listing_repository.dart';

/// Provider pour gérer les détails d'une annonce
class ListingDetailProvider extends ChangeNotifier {
  final ListingRepository _listingRepository = ListingRepository();

  // État
  ListingModel? _listing;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentImageIndex = 0;

  // Getters
  ListingModel? get listing => _listing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentImageIndex => _currentImageIndex;

  /// Récupérer une annonce par ID
  Future<void> fetchListingById(String listingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listing = await _listingRepository.getListingById(listingId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger cette annonce.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream d'une annonce par ID (temps réel)
  Stream<ListingModel?> watchListingById(String listingId) {
    return _listingRepository.watchListingById(listingId);
  }

  /// Changer l'index de l'image du carousel
  void setCurrentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  /// Réinitialiser l'état
  void reset() {
    _listing = null;
    _isLoading = true;
    _errorMessage = null;
    _currentImageIndex = 0;
    notifyListeners();
  }
}

