import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logements_app/data/models/user_model.dart';
import 'package:logements_app/data/repositories/auth_repository.dart';

/// Provider du repository d'authentification
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider de l'état d'authentification Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Provider de l'utilisateur actuel (Firebase User)
final currentFirebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

/// Provider du profil utilisateur complet (UserModel)
final userProfileProvider =
    StreamProvider.family<UserModel?, String>((ref, userId) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getUserProfileStream(userId);
});

/// Provider du profil de l'utilisateur connecté
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) {
    return Stream.value(null);
  }

  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getUserProfileStream(user.uid);
});

/// Controller pour les actions d'authentification
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  /// Inscription avec email et mot de passe
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userCredential = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
      );

      await _authRepository.createOrUpdateUserProfile(user);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Connexion avec email et mot de passe
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Connexion avec Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final userCredential = await _authRepository.signInWithGoogle();

      // Vérifie si l'utilisateur existe déjà dans Firestore
      final existingUser = await _authRepository.getUserProfile(
        userCredential.user!.uid,
      );

      // Si c'est un nouvel utilisateur, créer le profil
      if (existingUser == null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          role: UserRole.tenant,
          createdAt: DateTime.now(),
        );

        await _authRepository.createOrUpdateUserProfile(user);
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mise à jour du rôle
  Future<void> updateRole(String userId, UserRole role) async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.updateUserRole(userId, role);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mise à jour du profil
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.updateUserProfile(
        userId: userId,
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider du controller d'authentification
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthController(authRepo);
});
