import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Types de logement
enum ListingType {
  apartment,
  house,
  studio,
  villa,
  room;

  String get displayName {
    switch (this) {
      case ListingType.apartment:
        return 'Appartement';
      case ListingType.house:
        return 'Maison';
      case ListingType.studio:
        return 'Studio';
      case ListingType.villa:
        return 'Villa';
      case ListingType.room:
        return 'Chambre';
    }
  }
}

/// Statut de l'annonce
enum ListingStatus {
  active,
  inactive,
  rented;

  String get displayName {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.inactive:
        return 'Inactive';
      case ListingStatus.rented:
        return 'Louée';
    }
  }
}

/// Modèle d'annonce
class ListingModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final ListingType type;
  final double price;
  final String city;
  final String neighborhood;
  final String address;
  final LatLng location;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> images;
  final ListingStatus status;
  final int views;
  final int favoritesCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ListingModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.city,
    required this.neighborhood,
    required this.address,
    required this.location,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    required this.images,
    this.status = ListingStatus.active,
    this.views = 0,
    this.favoritesCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crée un ListingModel depuis Firebase
  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locationData = data['location'] as GeoPoint;

    return ListingModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ListingType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ListingType.apartment,
      ),
      price: (data['price'] ?? 0).toDouble(),
      city: data['city'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      address: data['address'] ?? '',
      location: LatLng(locationData.latitude, locationData.longitude),
      area: (data['area'] ?? 0).toDouble(),
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      amenities: List<String>.from(data['amenities'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      status: ListingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ListingStatus.active,
      ),
      views: data['views'] ?? 0,
      favoritesCount: data['favoritesCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convertit en Map pour Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'type': type.name,
      'price': price,
      'city': city,
      'neighborhood': neighborhood,
      'address': address,
      'location': GeoPoint(location.latitude, location.longitude),
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'amenities': amenities,
      'images': images,
      'status': status.name,
      'views': views,
      'favoritesCount': favoritesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Copie avec modifications
  ListingModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    ListingType? type,
    double? price,
    String? city,
    String? neighborhood,
    String? address,
    LatLng? location,
    double? area,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    List<String>? images,
    ListingStatus? status,
    int? views,
    int? favoritesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      address: address ?? this.address,
      location: location ?? this.location,
      area: area ?? this.area,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      status: status ?? this.status,
      views: views ?? this.views,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
