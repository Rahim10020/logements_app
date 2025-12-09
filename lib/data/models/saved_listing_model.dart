import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle représentant un favori
class SavedListingModel {
  final String id;
  final String userId;
  final String listingId;
  final DateTime savedAt;

  SavedListingModel({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.savedAt,
  });

  /// Créer une instance depuis un document Firestore
  factory SavedListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedListingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      listingId: data['listingId'] ?? '',
      savedAt: (data['savedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'listingId': listingId,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}

