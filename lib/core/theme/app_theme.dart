import 'package:flutter/material.dart';
/// Gestionnaire de thème de l'application
class AppTheme {
  AppTheme._();
  static ThemeData get lightTheme => _buildLightTheme();
  static ThemeData get darkTheme => _buildDarkTheme();
  static ThemeData _buildLightTheme() {
    const primary = Color(0xFF2563EB);
    const secondary = Color(0xFF10B981);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
      ),
    );
  }
  static ThemeData _buildDarkTheme() {
    const primary = Color(0xFF3B82F6);
    const secondary = Color(0xFF10B981);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Color(0xFFF9FAFB),
      ),
    );
  }
}
