import 'package:appwrite/appwrite.dart';

/// Configuration Appwrite
class AppwriteConfig {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '68a3096a003719911bbf';
  static const String databaseId = 'togostay_db';
  static const String bucketId = '6825ee3b003c09a6dd3d';

  static Client? _client;
  static Storage? _storage;

  /// Initialise le client Appwrite
  static Client get client {
    _client ??= Client().setEndpoint(endpoint).setProject(projectId);
    return _client!;
  }

  /// Récupère le service Storage
  static Storage get storage {
    _storage ??= Storage(client);
    return _storage!;
  }

  /// Upload une image
  static Future<String> uploadImage(String filePath, String fileId) async {
    try {
      final file = await storage.createFile(
        bucketId: bucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: filePath),
      );

      return getImageUrl(file.$id);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Récupère l'URL d'une image
  static String getImageUrl(String fileId) {
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
  }

  /// Supprime une image
  static Future<void> deleteImage(String fileId) async {
    try {
      await storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}
