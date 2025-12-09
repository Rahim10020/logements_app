/// Configuration de l'application
class AppConfig {
  AppConfig._();
  static const String appName = 'Ahoe';
  static const String appVersion = '1.0.0';
  static const int listingsPerPage = 20;
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
  static const int maxImagesPerListing = 10;
  static const int imageQuality = 85;
  static const double defaultLatitude = 6.1256; // Lomé
  static const double defaultLongitude = 1.2223; // Lomé
  static const double defaultZoom = 13.0;
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const int minPasswordLength = 6;
  static const int maxDescriptionLength = 500;
  static const int minDescriptionLength = 20;
}
