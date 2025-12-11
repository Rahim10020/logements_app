import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';
import '../../../core/config/appwrite_config.dart';
import 'dart:io';
import '../../../data/models/listing_model.dart';
import '../../../data/repositories/listing_repository.dart';

/// Provider pour gérer l'ajout/édition d'annonces
class AddEditListingProvider extends ChangeNotifier {
  final ListingRepository _listingRepository = ListingRepository();
  final ImagePicker _picker = ImagePicker();

  // État
  bool _isLoading = false;
  String? _errorMessage;
  final List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  double _uploadProgress = 0.0;

  // Données du formulaire
  String _city = '';
  String _neighborhood = '';
  String _propertyType = '';
  int _bedrooms = 1;
  int _bathrooms = 1;
  double _area = 0;
  double _monthlyPrice = 0;
  String _description = '';
  String? _address;
  double? _latitude;
  double? _longitude;

  // Commodités
  bool _furnished = false;
  bool _airConditioning = false;
  bool _wifi = false;
  bool _parking = false;
  bool _equippedKitchen = false;
  bool _balcony = false;
  bool _generator = false;
  bool _waterTank = false;
  bool _borehole = false;
  bool _security = false;
  bool _fence = false;
  bool _tiledFloor = false;
  bool _ceilingFan = false;
  bool _individualElectricMeter = false;
  bool _individualWaterMeter = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<File> get selectedImages => _selectedImages;
  List<String> get uploadedImageUrls => _uploadedImageUrls;
  double get uploadProgress => _uploadProgress;
  String get city => _city;
  String get neighborhood => _neighborhood;
  String get propertyType => _propertyType;
  int get bedrooms => _bedrooms;
  int get bathrooms => _bathrooms;
  double get area => _area;
  double get monthlyPrice => _monthlyPrice;
  String get description => _description;
  String? get address => _address;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Getters commodités
  bool get furnished => _furnished;
  bool get airConditioning => _airConditioning;
  bool get wifi => _wifi;
  bool get parking => _parking;
  bool get equippedKitchen => _equippedKitchen;
  bool get balcony => _balcony;
  bool get generator => _generator;
  bool get waterTank => _waterTank;
  bool get borehole => _borehole;
  bool get security => _security;
  bool get fence => _fence;
  bool get tiledFloor => _tiledFloor;
  bool get ceilingFan => _ceilingFan;
  bool get individualElectricMeter => _individualElectricMeter;
  bool get individualWaterMeter => _individualWaterMeter;

  /// Vérifier si le formulaire est valide
  bool get isFormValid {
    return _city.isNotEmpty &&
        _neighborhood.isNotEmpty &&
        _propertyType.isNotEmpty &&
        _area > 0 &&
        _monthlyPrice > 0 &&
        _description.isNotEmpty;
  }

  /// Setters
  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  void setNeighborhood(String value) {
    _neighborhood = value;
    notifyListeners();
  }

  void setPropertyType(String value) {
    _propertyType = value;
    notifyListeners();
  }

  void setBedrooms(int value) {
    _bedrooms = value;
    notifyListeners();
  }

  void setBathrooms(int value) {
    _bathrooms = value;
    notifyListeners();
  }

  void setArea(double value) {
    _area = value;
    notifyListeners();
  }

  void setMonthlyPrice(double value) {
    _monthlyPrice = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setAddress(String? value) {
    _address = value;
    notifyListeners();
  }

  void setLocation(double? lat, double? lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  /// Toggle commodités
  void toggleFurnished() {
    _furnished = !_furnished;
    notifyListeners();
  }

  void toggleAirConditioning() {
    _airConditioning = !_airConditioning;
    notifyListeners();
  }

  void toggleWifi() {
    _wifi = !_wifi;
    notifyListeners();
  }

  void toggleParking() {
    _parking = !_parking;
    notifyListeners();
  }

  void toggleEquippedKitchen() {
    _equippedKitchen = !_equippedKitchen;
    notifyListeners();
  }

  void toggleBalcony() {
    _balcony = !_balcony;
    notifyListeners();
  }

  void toggleGenerator() {
    _generator = !_generator;
    notifyListeners();
  }

  void toggleWaterTank() {
    _waterTank = !_waterTank;
    notifyListeners();
  }

  void toggleBorehole() {
    _borehole = !_borehole;
    notifyListeners();
  }

  void toggleSecurity() {
    _security = !_security;
    notifyListeners();
  }

  void toggleFence() {
    _fence = !_fence;
    notifyListeners();
  }

  void toggleTiledFloor() {
    _tiledFloor = !_tiledFloor;
    notifyListeners();
  }

  void toggleCeilingFan() {
    _ceilingFan = !_ceilingFan;
    notifyListeners();
  }

  void toggleIndividualElectricMeter() {
    _individualElectricMeter = !_individualElectricMeter;
    notifyListeners();
  }

  void toggleIndividualWaterMeter() {
    _individualWaterMeter = !_individualWaterMeter;
    notifyListeners();
  }

  /// Sélectionner des images
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      // Limiter à 10 images au total
      final remainingSlots =
          10 - _selectedImages.length - _uploadedImageUrls.length;
      final imagesToAdd = images.take(remainingSlots).toList();

      for (var image in imagesToAdd) {
        _selectedImages.add(File(image.path));
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection des images.';
      notifyListeners();
    }
  }

  /// Retirer une image sélectionnée
  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  /// Retirer une image déjà uploadée
  void removeUploadedImage(int index) {
    _uploadedImageUrls.removeAt(index);
    notifyListeners();
  }

  /// Uploader les images vers Appwrite Storage
  Future<List<String>> _uploadImages(String userId) async {
    List<String> urls = [];
    
    // Init Appwrite
    final client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);
    final storage = Storage(client);

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final file = _selectedImages[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        final result = await storage.createFile(
          bucketId: AppwriteConfig.bucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(
            path: file.path,
            filename: fileName,
          ),
        );

        // Construct URL
        final url = '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.bucketId}/files/${result.$id}/view?project=${AppwriteConfig.projectId}';
        
        urls.add(url);
        
        // Update progress
        _uploadProgress = (i + 1) / _selectedImages.length;
        notifyListeners();
        
      } catch (e) {
        debugPrint('Erreur upload image $i: $e');
      }
    }

    return urls;
  }


  /// Créer une nouvelle annonce
  Future<void> createListing(String userId) async {
    if (!isFormValid) {
      _errorMessage = 'Veuillez remplir tous les champs requis.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      // Upload des images
      final imageUrls = await _uploadImages(userId);

      // Créer le modèle
      final listing = ListingModel(
        id: '', // Sera généré par Firestore
        userId: userId,
        city: _city,
        neighborhood: _neighborhood,
        propertyType: _propertyType,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        area: _area,
        monthlyPrice: _monthlyPrice,
        description: _description,
        imageIds: imageUrls,
        address: _address,
        latitude: _latitude,
        longitude: _longitude,
        furnished: _furnished,
        airConditioning: _airConditioning,
        wifi: _wifi,
        parking: _parking,
        equippedKitchen: _equippedKitchen,
        balcony: _balcony,
        generator: _generator,
        waterTank: _waterTank,
        borehole: _borehole,
        security: _security,
        fence: _fence,
        tiledFloor: _tiledFloor,
        ceilingFan: _ceilingFan,
        individualElectricMeter: _individualElectricMeter,
        individualWaterMeter: _individualWaterMeter,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _listingRepository.createListing(listing);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la création de l\'annonce.';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Charger une annonce existante pour édition
  Future<void> loadListing(String listingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final listing = await _listingRepository.getListingById(listingId);
      if (listing != null) {
        _city = listing.city;
        _neighborhood = listing.neighborhood;
        _propertyType = listing.propertyType;
        _bedrooms = listing.bedrooms;
        _bathrooms = listing.bathrooms;
        _area = listing.area;
        _monthlyPrice = listing.monthlyPrice;
        _description = listing.description;
        _address = listing.address;
        _latitude = listing.latitude;
        _longitude = listing.longitude;
        _uploadedImageUrls = List.from(listing.imageIds);

        _furnished = listing.furnished;
        _airConditioning = listing.airConditioning;
        _wifi = listing.wifi;
        _parking = listing.parking;
        _equippedKitchen = listing.equippedKitchen;
        _balcony = listing.balcony;
        _generator = listing.generator;
        _waterTank = listing.waterTank;
        _borehole = listing.borehole;
        _security = listing.security;
        _fence = listing.fence;
        _tiledFloor = listing.tiledFloor;
        _ceilingFan = listing.ceilingFan;
        _individualElectricMeter = listing.individualElectricMeter;
        _individualWaterMeter = listing.individualWaterMeter;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger l\'annonce.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour une annonce existante
  Future<void> updateListing(String listingId, String userId) async {
    if (!isFormValid) {
      _errorMessage = 'Veuillez remplir tous les champs requis.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      // Upload nouvelles images si nécessaire
      List<String> newImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        newImageUrls = await _uploadImages(userId);
      }

      // Combiner anciennes et nouvelles images
      final allImageUrls = [..._uploadedImageUrls, ...newImageUrls];

      // Récupérer l'annonce actuelle pour garder certaines données
      final currentListing = await _listingRepository.getListingById(listingId);

      if (currentListing != null) {
        final updatedListing = ListingModel(
          id: listingId,
          userId: userId,
          city: _city,
          neighborhood: _neighborhood,
          propertyType: _propertyType,
          bedrooms: _bedrooms,
          bathrooms: _bathrooms,
          area: _area,
          monthlyPrice: _monthlyPrice,
          description: _description,
          imageIds: allImageUrls,
          address: _address,
          latitude: _latitude,
          longitude: _longitude,
          furnished: _furnished,
          airConditioning: _airConditioning,
          wifi: _wifi,
          parking: _parking,
          equippedKitchen: _equippedKitchen,
          balcony: _balcony,
          generator: _generator,
          waterTank: _waterTank,
          borehole: _borehole,
          security: _security,
          fence: _fence,
          tiledFloor: _tiledFloor,
          ceilingFan: _ceilingFan,
          individualElectricMeter: _individualElectricMeter,
          individualWaterMeter: _individualWaterMeter,
          isRented: currentListing.isRented,
          createdAt: currentListing.createdAt,
          updatedAt: DateTime.now(),
          favoritesCount: currentListing.favoritesCount,
        );

        await _listingRepository.updateListing(listingId, updatedListing);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de l\'annonce.';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Réinitialiser le formulaire
  void reset() {
    _city = '';
    _neighborhood = '';
    _propertyType = '';
    _bedrooms = 1;
    _bathrooms = 1;
    _area = 0;
    _monthlyPrice = 0;
    _description = '';
    _address = null;
    _latitude = null;
    _longitude = null;
    _selectedImages.clear();
    _uploadedImageUrls.clear();
    _uploadProgress = 0.0;

    _furnished = false;
    _airConditioning = false;
    _wifi = false;
    _parking = false;
    _equippedKitchen = false;
    _balcony = false;
    _generator = false;
    _waterTank = false;
    _borehole = false;
    _security = false;
    _fence = false;
    _tiledFloor = false;
    _ceilingFan = false;
    _individualElectricMeter = false;
    _individualWaterMeter = false;

    _errorMessage = null;
    notifyListeners();
  }
}
