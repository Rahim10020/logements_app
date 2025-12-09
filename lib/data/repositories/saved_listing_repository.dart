import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saved_listing_model.dart';
import '../models/listing_model.dart';

/// Repository pour gérer les favoris
class SavedListingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'saved_listings';

  /// Récupérer tous les favoris d'un utilisateur
  Future<List<SavedListingModel>> getSavedListings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('savedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SavedListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }

  /// Stream des favoris d'un utilisateur (temps réel)
  Stream<List<SavedListingModel>> watchSavedListings(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedListingModel.fromFirestore(doc))
            .toList());
  }

  /// Vérifier si une annonce est dans les favoris
  Future<bool> isListingSaved(String userId, String listingId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('listingId', isEqualTo: listingId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du favori: $e');
    }
  }

  /// Ajouter une annonce aux favoris
  Future<void> addToSaved(String userId, String listingId) async {
    try {
      // Vérifier si déjà sauvegardé
      final alreadySaved = await isListingSaved(userId, listingId);
      if (alreadySaved) {
        return;
      }

      final savedListing = SavedListingModel(
        id: '',
        userId: userId,
        listingId: listingId,
        savedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .add(savedListing.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  /// Retirer une annonce des favoris
  Future<void> removeFromSaved(String userId, String listingId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('listingId', isEqualTo: listingId)
          .limit(1)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du favori: $e');
    }
  }

  /// Récupérer les annonces complètes des favoris d'un utilisateur
  Future<List<ListingModel>> getSavedListingsWithDetails(String userId) async {
    try {
      // Récupérer les IDs des favoris
      final savedListings = await getSavedListings(userId);
      final listingIds = savedListings.map((s) => s.listingId).toList();

      if (listingIds.isEmpty) {
        return [];
      }

      // Récupérer les détails des annonces
      // Note: Firestore a une limite de 10 éléments pour le 'whereIn'
      // Pour plus de 10, il faudra faire plusieurs requêtes
      final List<ListingModel> listings = [];
      
      // Traiter par lots de 10
      for (int i = 0; i < listingIds.length; i += 10) {
        final batch = listingIds.skip(i).take(10).toList();
        final querySnapshot = await _firestore
            .collection('listings')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        listings.addAll(
          querySnapshot.docs.map((doc) => ListingModel.fromFirestore(doc)),
        );
      }

      return listings;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris avec détails: $e');
    }
  }
}

