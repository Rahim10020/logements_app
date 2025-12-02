import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logements_app/data/models/user_model.dart';

/// Repository d'authentification
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Récupère l'utilisateur actuel
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Récupère l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Inscription avec email et mot de passe
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  /// Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  /// Connexion avec Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  /// Crée ou met à jour le profil utilisateur dans Firestore
  Future<void> createOrUpdateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Erreur lors de la création du profil: $e');
    }
  }

  /// Récupère le profil utilisateur depuis Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  /// Stream du profil utilisateur
  Stream<UserModel?> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Met à jour le rôle de l'utilisateur
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du rôle: $e');
    }
  }

  /// Met à jour le profil utilisateur
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }
}
