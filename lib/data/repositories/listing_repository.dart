import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logements_app/data/models/listing_model.dart';
import 'package:logements_app/data/models/search_filter.dart';

/// Repository des annonces
class ListingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère toutes les annonces actives
  Stream<List<ListingModel>> getListings({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _firestore
        .collection('listings')
        .where('status', isEqualTo: ListingStatus.active.name)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Recherche d'annonces avec filtres
  Stream<List<ListingModel>> searchListings(SearchFilter filter) {
    Query query = _firestore
        .collection('listings')
        .where('status', isEqualTo: ListingStatus.active.name);

    if (filter.city != null) {
      query = query.where('city', isEqualTo: filter.city);
    }

    if (filter.neighborhood != null) {
      query = query.where('neighborhood', isEqualTo: filter.neighborhood);
    }

    if (filter.type != null) {
      query = query.where('type', isEqualTo: filter.type!.name);
    }

    if (filter.minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: filter.minPrice);
    }

    if (filter.maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: filter.maxPrice);
    }

    return query.snapshots().map((snapshot) {
      var listings =
          snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList();

      // Filtres supplémentaires (non supportés par Firestore directement)
      if (filter.minArea != null) {
        listings = listings.where((l) => l.area >= filter.minArea!).toList();
      }

      if (filter.maxArea != null) {
        listings = listings.where((l) => l.area <= filter.maxArea!).toList();
      }

      if (filter.minBedrooms != null) {
        listings =
            listings.where((l) => l.bedrooms >= filter.minBedrooms!).toList();
      }

      if (filter.minBathrooms != null) {
        listings =
            listings.where((l) => l.bathrooms >= filter.minBathrooms!).toList();
      }

      if (filter.amenities != null && filter.amenities!.isNotEmpty) {
        listings = listings
            .where((l) => filter.amenities!
                .every((amenity) => l.amenities.contains(amenity)))
            .toList();
      }

      return listings;
    });
  }

  /// Récupère une annonce par ID
  Future<ListingModel?> getListingById(String id) async {
    try {
      final doc = await _firestore.collection('listings').doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return ListingModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'annonce: $e');
    }
  }

  /// Stream d'une annonce par ID
  Stream<ListingModel?> getListingStream(String id) {
    return _firestore
        .collection('listings')
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? ListingModel.fromFirestore(doc) : null);
  }

  /// Récupère les annonces d'un propriétaire
  Stream<List<ListingModel>> getOwnerListings(String ownerId) {
    return _firestore
        .collection('listings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  /// Crée une nouvelle annonce
  Future<String> createListing(ListingModel listing) async {
    try {
      final docRef = await _firestore.collection('listings').add(
            listing.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'annonce: $e');
    }
  }

  /// Met à jour une annonce
  Future<void> updateListing(ListingModel listing) async {
    try {
      await _firestore.collection('listings').doc(listing.id).update(
            listing.toFirestore(),
          );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'annonce: $e');
    }
  }

  /// Supprime une annonce
  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection('listings').doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'annonce: $e');
    }
  }

  /// Incrémente le compteur de vues
  Future<void> incrementViews(String id) async {
    try {
      await _firestore.collection('listings').doc(id).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      // Ignore silencieusement les erreurs de vue
    }
  }

  /// Met à jour le statut d'une annonce
  Future<void> updateListingStatus(String id, ListingStatus status) async {
    try {
      await _firestore.collection('listings').doc(id).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Récupère les quartiers d'une ville
  Future<List<String>> getNeighborhoods(String city) async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('city', isEqualTo: city)
          .get();

      final neighborhoods = snapshot.docs
          .map((doc) => (doc.data())['neighborhood'] as String)
          .toSet()
          .toList();

      neighborhoods.sort();
      return neighborhoods;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des quartiers: $e');
    }
  }

  /// Récupère toutes les villes
  Future<List<String>> getCities() async {
    try {
      final snapshot = await _firestore.collection('listings').get();

      final cities = snapshot.docs
          .map((doc) => (doc.data())['city'] as String)
          .toSet()
          .toList();

      cities.sort();
      return cities;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des villes: $e');
    }
  }
}
