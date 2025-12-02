import 'package:intl/intl.dart';

/// Utilitaires pour le formatage
class FormatUtils {
  /// Formate le prix avec séparateur de milliers
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  /// Formate la surface
  static String formatArea(double area) {
    return '${area.toStringAsFixed(0)} m²';
  }

  /// Formate la date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'fr_FR');
    return formatter.format(date);
  }

  /// Formate la date et l'heure
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    return formatter.format(dateTime);
  }

  /// Formate un temps relatif (il y a X jours)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'il y a $years ${years > 1 ? 'ans' : 'an'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} ${difference.inDays > 1 ? 'jours' : 'jour'}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} ${difference.inHours > 1 ? 'heures' : 'heure'}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} ${difference.inMinutes > 1 ? 'minutes' : 'minute'}';
    } else {
      return 'à l\'instant';
    }
  }

  /// Formate le numéro de téléphone
  static String formatPhoneNumber(String phone) {
    if (phone.length == 8) {
      return '${phone.substring(0, 2)} ${phone.substring(2, 4)} ${phone.substring(4, 6)} ${phone.substring(6)}';
    }
    return phone;
  }
}
