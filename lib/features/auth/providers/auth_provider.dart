import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../core/config/firebase_config.dart';

/// Provider pour gérer l'authentification des utilisateurs
/// Gère la connexion, l'inscription, la réinitialisation du mot de passe
/// et les authentifications sociales (Google, Facebook)
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // État actuel de l'utilisateur
  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Écouter les changements d'état d'authentification
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Callback appelé quand l'état d'authentification change
  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  /// Charger les données utilisateur depuis Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection(FirebaseConfig.usersCollection).doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromJson({...doc.data()!, 'id': doc.id});
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  /// Connexion avec email et mot de passe
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      notifyListeners();
      return false;
    }
  }

  /// Inscription avec email et mot de passe
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String city,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Créer le compte Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Mettre à jour le profil
        await credential.user!.updateDisplayName(displayName);

        // Créer le document utilisateur dans Firestore
        final userDoc = UserModel(
          id: credential.user!.uid,
          uid: credential.user!.uid,
          email: email.trim(),
          displayName: displayName,
          phone: phone,
          city: city,
          role: '', // Sera défini dans l'écran de sélection de rôle
          photoURL: '',
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(credential.user!.uid)
            .set(userDoc.toJson());

        _userModel = userDoc;
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      notifyListeners();
      return false;
    }
  }

  /// Connexion avec Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Se connecter avec le fournisseur Google via FirebaseAuth
      final userCredential =
          await _auth.signInWithProvider(GoogleAuthProvider());

      if (userCredential.user != null) {
        // Vérifier si l'utilisateur existe déjà dans Firestore
        final userDoc = await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Créer un nouveau document utilisateur
          final newUser = UserModel(
            id: userCredential.user!.uid,
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName ?? '',
            phone: '',
            city: '',
            role: '', // Sera défini dans l'écran de sélection de rôle
            photoURL: userCredential.user!.photoURL ?? '',
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection(FirebaseConfig.usersCollection)
              .doc(userCredential.user!.uid)
              .set(newUser.toJson());
        }

        await _loadUserData(userCredential.user!.uid);
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Erreur lors de la connexion avec Google.';
      notifyListeners();
      return false;
    }
  }

  /// Connexion avec Facebook (placeholder - nécessite configuration FB)
  Future<bool> signInWithFacebook() async {
    // TODO: Implémenter l'authentification Facebook
    _errorMessage = 'Authentification Facebook non configurée.';
    notifyListeners();
    return false;
  }

  /// Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _auth.sendPasswordResetEmail(email: email.trim());

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour le rôle de l'utilisateur
  Future<bool> updateUserRole(String role) async {
    try {
      if (_currentUser == null) return false;

      _setLoading(true);
      _errorMessage = null;

      await _firestore.collection(FirebaseConfig.usersCollection).doc(_currentUser!.uid).update({
        'role': role,
      });

      if (_userModel != null) {
        _userModel = _userModel!.copyWith(role: role);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Erreur lors de la mise à jour du rôle.';
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userModel = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  /// Définir l'état de chargement
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Gérer les erreurs d'authentification Firebase
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = 'Aucun utilisateur trouvé avec cet email.';
        break;
      case 'wrong-password':
        _errorMessage = 'Mot de passe incorrect.';
        break;
      case 'email-already-in-use':
        _errorMessage = 'Cet email est déjà utilisé.';
        break;
      case 'weak-password':
        _errorMessage = 'Le mot de passe est trop faible.';
        break;
      case 'invalid-email':
        _errorMessage = 'L\'email est invalide.';
        break;
      case 'user-disabled':
        _errorMessage = 'Ce compte a été désactivé.';
        break;
      default:
        _errorMessage = 'Une erreur est survenue: ${e.message}';
    }
    notifyListeners();
  }

  /// Effacer le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
