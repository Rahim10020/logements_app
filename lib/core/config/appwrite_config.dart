/// Configuration Appwrite
class AppwriteConfig {
  AppwriteConfig._();
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String databaseId = 'Ahoe_db';
  // Buckets
  static const String listingImagesBucket = 'listing_images';
  static const String profileImagesBucket = 'profile_images';
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
}
