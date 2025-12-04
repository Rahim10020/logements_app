import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:logements_app/data/repositories/favorite_repository.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';

/// Provider du repository des favoris
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

/// Provider des favoris de l'utilisateur connecté
final userFavoritesProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) {
    return Stream.value([]);
  }

  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.getUserFavorites(user.uid);
});

/// Provider pour vérifier si une annonce est en favoris
final isFavoriteProvider = Provider.family<bool, String>((ref, listingId) {
  final favorites = ref.watch(userFavoritesProvider);
  return favorites.maybeWhen(
    data: (favs) => favs.contains(listingId),
    orElse: () => false,
  );
});

/// Controller pour les actions sur les favoris
class FavoriteController extends StateNotifier<AsyncValue<void>> {
  final FavoriteRepository _repository;
  final String userId;

  FavoriteController(this._repository, this.userId)
      : super(const AsyncValue.data(null));

  /// Toggle favoris
  Future<void> toggleFavorite(String listingId) async {
    try {
      await _repository.toggleFavorite(userId, listingId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Ajoute aux favoris
  Future<void> addToFavorites(String listingId) async {
    try {
      await _repository.addToFavorites(userId, listingId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Retire des favoris
  Future<void> removeFromFavorites(String listingId) async {
    try {
      await _repository.removeFromFavorites(userId, listingId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider du controller des favoris
final favoriteControllerProvider =
    StateNotifierProvider<FavoriteController, AsyncValue<void>>((ref) {
  final repo = ref.watch(favoriteRepositoryProvider);
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return FavoriteController(repo, user.uid);
});
