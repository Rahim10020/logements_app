/// Liste des commodités disponibles pour les logements
class Amenities {
  static const List<AmenityItem> all = [
    AmenityItem(
      id: 'wifi',
      name: 'WiFi',
      icon: 'wifi',
      category: AmenityCategory.technology,
    ),
    AmenityItem(
      id: 'parking',
      name: 'Parking',
      icon: 'local_parking',
      category: AmenityCategory.outdoor,
    ),
    AmenityItem(
      id: 'air_conditioning',
      name: 'Climatisation',
      icon: 'ac_unit',
      category: AmenityCategory.comfort,
    ),
    AmenityItem(
      id: 'pool',
      name: 'Piscine',
      icon: 'pool',
      category: AmenityCategory.outdoor,
    ),
    AmenityItem(
      id: 'garden',
      name: 'Jardin',
      icon: 'yard',
      category: AmenityCategory.outdoor,
    ),
    AmenityItem(
      id: 'security',
      name: 'Gardiennage/Sécurité',
      icon: 'security',
      category: AmenityCategory.safety,
    ),
    AmenityItem(
      id: 'furnished',
      name: 'Meublé',
      icon: 'weekend',
      category: AmenityCategory.comfort,
    ),
    AmenityItem(
      id: 'kitchen',
      name: 'Cuisine équipée',
      icon: 'kitchen',
      category: AmenityCategory.comfort,
    ),
    AmenityItem(
      id: 'washing_machine',
      name: 'Machine à laver',
      icon: 'local_laundry_service',
      category: AmenityCategory.appliances,
    ),
    AmenityItem(
      id: 'tv',
      name: 'Télévision',
      icon: 'tv',
      category: AmenityCategory.technology,
    ),
    AmenityItem(
      id: 'balcony',
      name: 'Balcon',
      icon: 'balcony',
      category: AmenityCategory.outdoor,
    ),
    AmenityItem(
      id: 'terrace',
      name: 'Terrasse',
      icon: 'deck',
      category: AmenityCategory.outdoor,
    ),
    AmenityItem(
      id: 'elevator',
      name: 'Ascenseur',
      icon: 'elevator',
      category: AmenityCategory.building,
    ),
    AmenityItem(
      id: 'generator',
      name: 'Groupe électrogène',
      icon: 'power',
      category: AmenityCategory.utilities,
    ),
    AmenityItem(
      id: 'water_heater',
      name: 'Chauffe-eau',
      icon: 'hot_tub',
      category: AmenityCategory.utilities,
    ),
    AmenityItem(
      id: 'fridge',
      name: 'Réfrigérateur',
      icon: 'kitchen',
      category: AmenityCategory.appliances,
    ),
    AmenityItem(
      id: 'microwave',
      name: 'Micro-ondes',
      icon: 'microwave',
      category: AmenityCategory.appliances,
    ),
    AmenityItem(
      id: 'gym',
      name: 'Salle de sport',
      icon: 'fitness_center',
      category: AmenityCategory.building,
    ),
    AmenityItem(
      id: 'playground',
      name: 'Aire de jeux',
      icon: 'playground',
      category: AmenityCategory.outdoor,
    ),
    AmenityItem(
      id: 'pet_friendly',
      name: 'Animaux acceptés',
      icon: 'pets',
      category: AmenityCategory.policies,
    ),
  ];

  /// Récupère une commodité par son ID
  static AmenityItem? getById(String id) {
    try {
      return all.firstWhere((amenity) => amenity.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Récupère les commodités par catégorie
  static List<AmenityItem> getByCategory(AmenityCategory category) {
    return all.where((amenity) => amenity.category == category).toList();
  }
}

/// Catégories de commodités
enum AmenityCategory {
  technology('Technologie'),
  comfort('Confort'),
  outdoor('Extérieur'),
  safety('Sécurité'),
  appliances('Électroménager'),
  building('Immeuble'),
  utilities('Utilitaires'),
  policies('Politiques');

  final String displayName;
  const AmenityCategory(this.displayName);
}

/// Item de commodité
class AmenityItem {
  final String id;
  final String name;
  final String icon;
  final AmenityCategory category;

  const AmenityItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
  });
}
