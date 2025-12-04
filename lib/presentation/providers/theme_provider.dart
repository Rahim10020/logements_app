import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

/// Provider du mode sombre
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

/// Notifier pour le mode sombre
class ThemeModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const String _key = 'isDarkMode';

  ThemeModeNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  /// Toggle le mode sombre
  Future<void> toggle() async {
    state = !state;
    await _prefs.setBool(_key, state);
  }

  /// Définit le mode sombre
  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    await _prefs.setBool(_key, isDark);
  }
}
