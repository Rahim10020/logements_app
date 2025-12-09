import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

/// Repository pour gérer les opérations CRUD sur les annonces
class ListingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'listings';

  /// Récupérer toutes les annonces disponibles
  Future<List<ListingModel>> getAllListings() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces: $e');
    }
  }

  /// Stream de toutes les annonces (temps réel)
  Stream<List<ListingModel>> watchAllListings() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  /// Récupérer une annonce par ID
  Future<ListingModel?> getListingById(String listingId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .get();

      if (doc.exists) {
        return ListingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'annonce: $e');
    }
  }

  /// Stream d'une annonce par ID (temps réel)
  Stream<ListingModel?> watchListingById(String listingId) {
    return _firestore
        .collection(_collectionName)
        .doc(listingId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ListingModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Récupérer les annonces par ville
  Future<List<ListingModel>> getListingsByCity(String city) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('city', isEqualTo: city)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces par ville: $e');
    }
  }

  /// Récupérer les annonces par quartier
  Future<List<ListingModel>> getListingsByNeighborhood(String neighborhood) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('neighborhood', isEqualTo: neighborhood)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces par quartier: $e');
    }
  }

  /// Récupérer les annonces d'un utilisateur
  Future<List<ListingModel>> getListingsByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces de l\'utilisateur: $e');
    }
  }

  /// Créer une nouvelle annonce
  Future<String> createListing(ListingModel listing) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(listing.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'annonce: $e');
    }
  }

  /// Mettre à jour une annonce
  Future<void> updateListing(String listingId, ListingModel listing) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .update(listing.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'annonce: $e');
    }
  }

  /// Supprimer une annonce
  Future<void> deleteListing(String listingId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'annonce: $e');
    }
  }

  /// Incrémenter le compteur de favoris
  Future<void> incrementFavoritesCount(String listingId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .update({'favoritesCount': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Erreur lors de l\'incrémentation des favoris: $e');
    }
  }

  /// Décrémenter le compteur de favoris
  Future<void> decrementFavoritesCount(String listingId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .update({'favoritesCount': FieldValue.increment(-1)});
    } catch (e) {
      throw Exception('Erreur lors de la décrémentation des favoris: $e');
    }
  }

  /// Rechercher des annonces avec filtres
  Future<List<ListingModel>> searchListings({
    String? city,
    String? neighborhood,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName);

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      if (neighborhood != null && neighborhood.isNotEmpty) {
        query = query.where('neighborhood', isEqualTo: neighborhood);
      }

      if (propertyType != null && propertyType.isNotEmpty) {
        query = query.where('propertyType', isEqualTo: propertyType);
      }

      final querySnapshot = await query.get();
      var listings = querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();

      // Filtres supplémentaires en mémoire (car Firestore a des limites sur les requêtes composées)
      if (minPrice != null) {
        listings = listings.where((l) => l.monthlyPrice >= minPrice).toList();
      }

      if (maxPrice != null) {
        listings = listings.where((l) => l.monthlyPrice <= maxPrice).toList();
      }

      if (minBedrooms != null) {
        listings = listings.where((l) => l.bedrooms >= minBedrooms).toList();
      }

      if (maxBedrooms != null) {
        listings = listings.where((l) => l.bedrooms <= maxBedrooms).toList();
      }

      return listings;
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'annonces: $e');
    }
  }
}

