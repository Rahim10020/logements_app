import 'package:flutter/foundation.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/saved_listing_model.dart';
import '../../../data/repositories/saved_listing_repository.dart';
import '../../../data/repositories/listing_repository.dart';

/// Provider pour gérer les favoris
class SavedProvider extends ChangeNotifier {
  final SavedListingRepository _savedRepository = SavedListingRepository();
  final ListingRepository _listingRepository = ListingRepository();

  // État
  List<ListingModel> _savedListings = [];
  Set<String> _savedListingIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<ListingModel> get savedListings => _savedListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get count => _savedListings.length;

  /// Récupérer les favoris de l'utilisateur
  Future<void> fetchSavedListings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _savedListings = await _savedRepository.getSavedListingsWithDetails(userId);
      _savedListingIds = _savedListings.map((l) => l.id).toSet();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger vos favoris.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream des favoris (temps réel)
  Stream<List<SavedListingModel>> watchSavedListings(String userId) {
    return _savedRepository.watchSavedListings(userId);
  }

  /// Ajouter une annonce aux favoris
  Future<void> addToSaved(String userId, String listingId) async {
    try {
      await _savedRepository.addToSaved(userId, listingId);
      await _listingRepository.incrementFavoritesCount(listingId);

      // Mettre à jour l'état local
      _savedListingIds.add(listingId);

      // Récupérer les détails de l'annonce
      final listing = await _listingRepository.getListingById(listingId);
      if (listing != null) {
        _savedListings.insert(0, listing);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible d\'ajouter aux favoris.';
      notifyListeners();
      rethrow;
    }
  }

  /// Retirer une annonce des favoris
  Future<void> removeFromSaved(String userId, String listingId) async {
    try {
      await _savedRepository.removeFromSaved(userId, listingId);
      await _listingRepository.decrementFavoritesCount(listingId);

      // Mettre à jour l'état local
      _savedListingIds.remove(listingId);
      _savedListings.removeWhere((l) => l.id == listingId);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de retirer des favoris.';
      notifyListeners();
      rethrow;
    }
  }

  /// Toggle favori (ajouter ou retirer)
  Future<void> toggleSaved(String userId, String listingId) async {
    if (isSaved(listingId)) {
      await removeFromSaved(userId, listingId);
    } else {
      await addToSaved(userId, listingId);
    }
  }

  /// Vérifier si une annonce est en favoris
  bool isSaved(String listingId) {
    return _savedListingIds.contains(listingId);
  }

  /// Charger les IDs des favoris uniquement (plus rapide)
  Future<void> loadSavedIds(String userId) async {
    try {
      final savedListings = await _savedRepository.getSavedListings(userId);
      _savedListingIds = savedListings.map((s) => s.listingId).toSet();
      notifyListeners();
    } catch (e) {
      // Erreur silencieuse pour ne pas bloquer l'UI
      debugPrint('Erreur lors du chargement des IDs favoris: $e');
    }
  }
}

