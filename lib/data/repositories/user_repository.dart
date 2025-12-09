import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository pour gérer les opérations sur les utilisateurs
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  /// Récupérer un utilisateur par ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  /// Créer un nouvel utilisateur
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser(String userId, UserModel user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  /// Vérifier si un utilisateur existe
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de l\'utilisateur: $e');
    }
  }

  /// Stream d'un utilisateur par ID (temps réel)
  Stream<UserModel?> watchUserById(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }
}

