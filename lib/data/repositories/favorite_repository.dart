import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository des favoris
class FavoriteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère les IDs des favoris d'un utilisateur
  Stream<List<String>> getUserFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Vérifie si une annonce est en favoris
  Future<bool> isFavorite(String userId, String listingId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(listingId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Ajoute une annonce aux favoris
  Future<void> addToFavorites(String userId, String listingId) async {
    try {
      final batch = _firestore.batch();

      // Ajoute aux favoris de l'utilisateur
      final favoriteRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(listingId);

      batch.set(favoriteRef, {
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Incrémente le compteur de favoris de l'annonce
      final listingRef = _firestore.collection('listings').doc(listingId);
      batch.update(listingRef, {
        'favoritesCount': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  /// Retire une annonce des favoris
  Future<void> removeFromFavorites(String userId, String listingId) async {
    try {
      final batch = _firestore.batch();

      // Retire des favoris de l'utilisateur
      final favoriteRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(listingId);

      batch.delete(favoriteRef);

      // Décrémente le compteur de favoris de l'annonce
      final listingRef = _firestore.collection('listings').doc(listingId);
      batch.update(listingRef, {
        'favoritesCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du retrait des favoris: $e');
    }
  }

  /// Toggle favoris
  Future<void> toggleFavorite(String userId, String listingId) async {
    final isFav = await isFavorite(userId, listingId);

    if (isFav) {
      await removeFromFavorites(userId, listingId);
    } else {
      await addToFavorites(userId, listingId);
    }
  }
}
