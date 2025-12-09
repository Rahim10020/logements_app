/// Données géographiques du Togo (villes et quartiers)
class TogoLocations {
  TogoLocations._();
  /// Villes du Togo avec leurs quartiers
  static const Map<String, List<String>> citiesWithNeighborhoods = {
    'Lomé': [
      'Agoè',
      'Bè',
      'Tokoin',
      'Adidogomé',
      'Nyékonakpoè',
      'Cacavéli',
      'Hédzranawoé',
      'Légbassito',
      'Amadahomé',
      'Avedji',
      'Centre-ville',
    ],
    'Kara': [
      'Tomdè',
      'Centre-ville Kara',
      'Sarakawa',
      'Tchaoudjo',
    ],
    'Sokodé': [
      'Komah',
      'Kpangalam',
      'Centre-ville Sokodé',
    ],
    'Atakpamé': [
      'Centre-ville Atakpamé',
      'Agbélouvé',
    ],
    'Kpalimé': [
      'Centre-ville Kpalimé',
      'Kpadapé',
    ],
  };
  /// Liste de toutes les villes
  static List<String> get cities => citiesWithNeighborhoods.keys.toList();
  /// Obtenir les quartiers d'une ville
  static List<String> getNeighborhoods(String city) {
    return citiesWithNeighborhoods[city] ?? [];
  }
  /// Types de propriétés disponibles
  static const List<String> propertyTypes = [
    'Appartement',
    'Maison',
    'Studio',
    'Villa',
    'Duplex',
    'Chambre meublée',
  ];
}
