import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle représentant une annonce immobilière
class ListingModel {
  final String id;
  final String userId;
  final String city;
  final String neighborhood;
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final double monthlyPrice;
  final String description;
  final bool isRented;
  final List<String> imageIds;
  final double? latitude;
  final double? longitude;
  final String? address;
  
  // Commodités
  final bool furnished;
  final bool airConditioning;
  final bool wifi;
  final bool parking;
  final bool equippedKitchen;
  final bool balcony;
  final bool generator;
  final bool waterTank;
  final bool borehole;
  final bool security;
  final bool fence;
  final bool tiledFloor;
  final bool ceilingFan;
  final bool individualElectricMeter;
  final bool individualWaterMeter;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final int favoritesCount;

  ListingModel({
    required this.id,
    required this.userId,
    required this.city,
    required this.neighborhood,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.monthlyPrice,
    required this.description,
    this.isRented = false,
    this.imageIds = const [],
    this.latitude,
    this.longitude,
    this.address,
    this.furnished = false,
    this.airConditioning = false,
    this.wifi = false,
    this.parking = false,
    this.equippedKitchen = false,
    this.balcony = false,
    this.generator = false,
    this.waterTank = false,
    this.borehole = false,
    this.security = false,
    this.fence = false,
    this.tiledFloor = false,
    this.ceilingFan = false,
    this.individualElectricMeter = false,
    this.individualWaterMeter = false,
    required this.createdAt,
    required this.updatedAt,
    this.favoritesCount = 0,
  });

  /// Calcul du prix au m²
  double get pricePerSquareMeter => monthlyPrice / area;

  /// Liste des commodités disponibles avec leurs labels
  Map<String, bool> get amenitiesMap => {
    'Meublé': furnished,
    'Climatisation': airConditioning,
    'WiFi': wifi,
    'Parking': parking,
    'Cuisine équipée': equippedKitchen,
    'Balcon': balcony,
    'Générateur': generator,
    'Château d\'eau': waterTank,
    'Forage': borehole,
    'Sécurité': security,
    'Clôturé': fence,
    'Sol carrelé': tiledFloor,
    'Ventilateur': ceilingFan,
    'Compteur électrique individuel': individualElectricMeter,
    'Compteur d\'eau individuel': individualWaterMeter,
  };

  /// Liste des commodités actives uniquement
  List<String> get activeAmenities => amenitiesMap.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  /// Créer une instance depuis un document Firestore
  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      city: data['city'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      propertyType: data['propertyType'] ?? '',
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      area: (data['area'] ?? 0).toDouble(),
      monthlyPrice: (data['monthlyPrice'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      isRented: data['isRented'] ?? false,
      imageIds: List<String>.from(data['imageIds'] ?? []),
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      address: data['address'],
      furnished: data['furnished'] ?? false,
      airConditioning: data['airConditioning'] ?? false,
      wifi: data['wifi'] ?? false,
      parking: data['parking'] ?? false,
      equippedKitchen: data['equippedKitchen'] ?? false,
      balcony: data['balcony'] ?? false,
      generator: data['generator'] ?? false,
      waterTank: data['waterTank'] ?? false,
      borehole: data['borehole'] ?? false,
      security: data['security'] ?? false,
      fence: data['fence'] ?? false,
      tiledFloor: data['tiledFloor'] ?? false,
      ceilingFan: data['ceilingFan'] ?? false,
      individualElectricMeter: data['individualElectricMeter'] ?? false,
      individualWaterMeter: data['individualWaterMeter'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      favoritesCount: data['favoritesCount'] ?? 0,
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'city': city,
      'neighborhood': neighborhood,
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'monthlyPrice': monthlyPrice,
      'description': description,
      'isRented': isRented,
      'imageIds': imageIds,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'furnished': furnished,
      'airConditioning': airConditioning,
      'wifi': wifi,
      'parking': parking,
      'equippedKitchen': equippedKitchen,
      'balcony': balcony,
      'generator': generator,
      'waterTank': waterTank,
      'borehole': borehole,
      'security': security,
      'fence': fence,
      'tiledFloor': tiledFloor,
      'ceilingFan': ceilingFan,
      'individualElectricMeter': individualElectricMeter,
      'individualWaterMeter': individualWaterMeter,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'favoritesCount': favoritesCount,
    };
  }

  /// Copier avec modifications
  ListingModel copyWith({
    String? id,
    String? userId,
    String? city,
    String? neighborhood,
    String? propertyType,
    int? bedrooms,
    int? bathrooms,
    double? area,
    double? monthlyPrice,
    String? description,
    bool? isRented,
    List<String>? imageIds,
    double? latitude,
    double? longitude,
    String? address,
    bool? furnished,
    bool? airConditioning,
    bool? wifi,
    bool? parking,
    bool? equippedKitchen,
    bool? balcony,
    bool? generator,
    bool? waterTank,
    bool? borehole,
    bool? security,
    bool? fence,
    bool? tiledFloor,
    bool? ceilingFan,
    bool? individualElectricMeter,
    bool? individualWaterMeter,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? favoritesCount,
  }) {
    return ListingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      propertyType: propertyType ?? this.propertyType,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      description: description ?? this.description,
      isRented: isRented ?? this.isRented,
      imageIds: imageIds ?? this.imageIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      furnished: furnished ?? this.furnished,
      airConditioning: airConditioning ?? this.airConditioning,
      wifi: wifi ?? this.wifi,
      parking: parking ?? this.parking,
      equippedKitchen: equippedKitchen ?? this.equippedKitchen,
      balcony: balcony ?? this.balcony,
      generator: generator ?? this.generator,
      waterTank: waterTank ?? this.waterTank,
      borehole: borehole ?? this.borehole,
      security: security ?? this.security,
      fence: fence ?? this.fence,
      tiledFloor: tiledFloor ?? this.tiledFloor,
      ceilingFan: ceilingFan ?? this.ceilingFan,
      individualElectricMeter: individualElectricMeter ?? this.individualElectricMeter,
      individualWaterMeter: individualWaterMeter ?? this.individualWaterMeter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favoritesCount: favoritesCount ?? this.favoritesCount,
    );
  }
}

