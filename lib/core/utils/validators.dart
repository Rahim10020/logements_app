import '../config/app_config.dart';
/// Validateurs pour les formulaires
class Validators {
  Validators._();
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < AppConfig.minPasswordLength) {
      return 'Mot de passe trop court (min ${AppConfig.minPasswordLength} caractères)';
    }
    return null;
  }
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Téléphone requis';
    }
    final phoneRegex = RegExp(r'^(\+?228)?[0-9]{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro invalide';
    }
    return null;
  }
}
