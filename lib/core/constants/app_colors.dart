import 'package:flutter/material.dart';

/// Couleurs de l'application TogoStay
class AppColors {
  AppColors._(); // Constructeur privé pour empêcher l'instanciation

  // Couleurs primaires
  static const Color primary = Color(0xFF2563EB); // Bleu moderne
  static const Color secondary = Color(0xFF10B981); // Vert pour succès
  static const Color accent = Color(0xFFF59E0B); // Orange pour actions importantes

  // Couleurs neutres
  static const Color grey600 = Color(0xFF6B7280);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey50 = Color(0xFFF9FAFB);

  // Couleurs de texte
  static const Color textDark = Color(0xFF111827);
  static const Color textLight = Color(0xFFF9FAFB);
  static const Color textGrey = Color(0xFF6B7280);

  // Couleurs de statut
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Couleurs de fond
  static const Color background = Color(0xFFF9FAFB); // Fond principal
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1F2937);

  // Couleurs de badge
  static const Color badgeAvailable = Color(0xFF10B981);
  static const Color badgeRented = Color(0xFFF59E0B);
}

