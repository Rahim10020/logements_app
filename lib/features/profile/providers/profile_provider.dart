import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

/// Provider pour gérer le profil utilisateur
class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _picker = ImagePicker();

  // État
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  File? _selectedImage;
  bool _isUpdating = false;
  double _uploadProgress = 0.0;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;
  bool get isUpdating => _isUpdating;
  double get uploadProgress => _uploadProgress;

  /// Charger le profil de l'utilisateur
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userRepository.getUserById(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger le profil.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream du profil (temps réel)
  Stream<UserModel?> watchProfile(String userId) {
    return _userRepository.watchUserById(userId);
  }

  /// Sélectionner une photo de profil
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection de l\'image.';
      notifyListeners();
    }
  }

  /// Annuler la sélection d'image
  void cancelImageSelection() {
    _selectedImage = null;
    notifyListeners();
  }

  /// Upload photo de profil vers Firebase Storage
  Future<String?> _uploadProfileImage(String userId) async {
    if (_selectedImage == null) return null;

    try {
      final fileName = 'profile_$userId.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('profiles')
          .child(userId)
          .child(fileName);

      final uploadTask = ref.putFile(_selectedImage!);

      // Suivre la progression
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });

      await uploadTask;
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Erreur upload image: $e');
      return null;
    }
  }

  /// Mettre à jour le profil
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? phone,
    String? city,
    bool? uploadNewImage,
  }) async {
    if (_user == null) return;

    _isUpdating = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      String? photoURL = _user!.photoURL;

      // Upload nouvelle image si sélectionnée
      if (uploadNewImage == true && _selectedImage != null) {
        photoURL = await _uploadProfileImage(userId);
      }

      // Créer le modèle mis à jour
      final updatedUser = _user!.copyWith(
        displayName: displayName ?? _user!.displayName,
        phone: phone ?? _user!.phone,
        city: city ?? _user!.city,
        photoURL: photoURL,
      );

      await _userRepository.updateUser(userId, updatedUser);

      // Mettre à jour localement
      _user = updatedUser;
      _selectedImage = null;
      _isUpdating = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil.';
      _isUpdating = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Rafraîchir le profil
  Future<void> refresh(String userId) async {
    await loadProfile(userId);
  }
}

