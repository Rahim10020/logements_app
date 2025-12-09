import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour gérer le thème de l'application (dark/light mode)
class ThemeNotifier extends Notifier<bool> {
  static const String _themeKey = 'isDarkMode';

  @override
  bool build() {
    _loadTheme();
    return false;
  }

  /// Charger la préférence de thème depuis le stockage local
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_themeKey) ?? false;
  }

  /// Basculer entre le mode sombre et clair
  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, state);
  }

  /// Définir le mode sombre
  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}

/// Provider Riverpod pour le thème
final themeProvider = NotifierProvider<ThemeNotifier, bool>(() {
  return ThemeNotifier();
});

