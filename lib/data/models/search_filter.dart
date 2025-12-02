import 'package:logements_app/data/models/listing_model.dart';

/// Modèle de filtre de recherche
class SearchFilter {
  final String? city;
  final String? neighborhood;
  final ListingType? type;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int? minBedrooms;
  final int? minBathrooms;
  final List<String>? amenities;

  SearchFilter({
    this.city,
    this.neighborhood,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.minBedrooms,
    this.minBathrooms,
    this.amenities,
  });

  /// Vérifie si le filtre est vide
  bool get isEmpty {
    return city == null &&
        neighborhood == null &&
        type == null &&
        minPrice == null &&
        maxPrice == null &&
        minArea == null &&
        maxArea == null &&
        minBedrooms == null &&
        minBathrooms == null &&
        (amenities == null || amenities!.isEmpty);
  }

  /// Copie avec modifications
  SearchFilter copyWith({
    String? city,
    String? neighborhood,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? minBedrooms,
    int? minBathrooms,
    List<String>? amenities,
  }) {
    return SearchFilter(
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      amenities: amenities ?? this.amenities,
    );
  }

  /// Réinitialise le filtre
  SearchFilter clear() {
    return SearchFilter();
  }

  /// Convertit en Map
  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'neighborhood': neighborhood,
      'type': type?.name,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minArea': minArea,
      'maxArea': maxArea,
      'minBedrooms': minBedrooms,
      'minBathrooms': minBathrooms,
      'amenities': amenities,
    };
  }

  /// Crée depuis Map
  factory SearchFilter.fromMap(Map<String, dynamic> map) {
    return SearchFilter(
      city: map['city'],
      neighborhood: map['neighborhood'],
      type: map['type'] != null
          ? ListingType.values.firstWhere((e) => e.name == map['type'])
          : null,
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      minArea: map['minArea']?.toDouble(),
      maxArea: map['maxArea']?.toDouble(),
      minBedrooms: map['minBedrooms'],
      minBathrooms: map['minBathrooms'],
      amenities:
          map['amenities'] != null ? List<String>.from(map['amenities']) : null,
    );
  }
}
