import 'package:flutter/foundation.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/repositories/listing_repository.dart';

/// Provider pour gérer le dashboard propriétaire
class DashboardProvider extends ChangeNotifier {
  final ListingRepository _listingRepository = ListingRepository();

  // État
  List<ListingModel> _myListings = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Statistiques
  int _totalViews = 0;
  int _totalFavorites = 0;
  int _totalContacts = 0;
  int _activeListings = 0;
  int _rentedListings = 0;

  // Getters
  List<ListingModel> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalViews => _totalViews;
  int get totalFavorites => _totalFavorites;
  int get totalContacts => _totalContacts;
  int get activeListings => _activeListings;
  int get rentedListings => _rentedListings;
  int get totalListings => _myListings.length;

  /// Récupérer les annonces du propriétaire
  Future<void> fetchMyListings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myListings = await _listingRepository.getListingsByUserId(userId);
      _calculateStatistics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger vos annonces.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculer les statistiques
  void _calculateStatistics() {
    _totalFavorites = 0;
    _activeListings = 0;
    _rentedListings = 0;

    for (var listing in _myListings) {
      _totalFavorites += listing.favoritesCount;
      if (listing.isRented) {
        _rentedListings++;
      } else {
        _activeListings++;
      }
    }

    // Les vues et contacts seraient stockés dans Firestore dans une vraie app
    _totalViews = _myListings.length * 45; // Simulation
    _totalContacts = _myListings.length * 12; // Simulation
  }

  /// Supprimer une annonce
  Future<void> deleteListing(String listingId) async {
    try {
      await _listingRepository.deleteListing(listingId);
      _myListings.removeWhere((l) => l.id == listingId);
      _calculateStatistics();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de supprimer l\'annonce.';
      notifyListeners();
      rethrow;
    }
  }

  /// Toggle statut loué/disponible
  Future<void> toggleRentedStatus(String listingId) async {
    try {
      final listing = _myListings.firstWhere((l) => l.id == listingId);
      final updatedListing = listing.copyWith(
        isRented: !listing.isRented,
        updatedAt: DateTime.now(),
      );

      await _listingRepository.updateListing(listingId, updatedListing);

      // Mettre à jour localement
      final index = _myListings.indexWhere((l) => l.id == listingId);
      _myListings[index] = updatedListing;
      _calculateStatistics();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de mettre à jour le statut.';
      notifyListeners();
      rethrow;
    }
  }

  /// Rafraîchir les données
  Future<void> refresh(String userId) async {
    await fetchMyListings(userId);
  }
}
