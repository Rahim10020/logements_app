/// Validateurs pour les formulaires
class Validators {
  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }

    return null;
  }

  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  /// Valide la confirmation du mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation du mot de passe requise';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Valide un champ requis
  static String? validateRequired(String? value,
      [String fieldName = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  /// Valide un numéro de téléphone
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }

    final phoneRegex = RegExp(r'^[0-9]{8}$');

    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide (8 chiffres)';
    }

    return null;
  }

  /// Valide un prix
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Prix requis';
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Prix invalide';
    }

    return null;
  }

  /// Valide une surface
  static String? validateArea(String? value) {
    if (value == null || value.isEmpty) {
      return 'Surface requise';
    }

    final area = double.tryParse(value);
    if (area == null || area <= 0) {
      return 'Surface invalide';
    }

    return null;
  }

  /// Valide un nombre
  static String? validateNumber(String? value,
      [String fieldName = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return '$fieldName invalide';
    }

    return null;
  }
}
