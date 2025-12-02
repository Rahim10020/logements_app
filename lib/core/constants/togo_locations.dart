/// Villes principales du Togo avec leurs quartiers
class TogoLocations {
  static const Map<String, List<String>> citiesWithNeighborhoods = {
    'Lomé': [
      'Adidogomé',
      'Agoè',
      'Bè',
      'Tokoin',
      'Nyékonakpoè',
      'Hanoukopé',
      'Gbossimé',
      'Hédzranawoé',
      'Cacavéli',
      'Gbényédzi',
      'Nukafu',
      'Amadahomé',
      'Vakpossito',
      'Démakpoé',
      'Légbassito',
    ],
    'Kara': [
      'Centre-ville',
      'Kpéwa',
      'Lama-Tessi',
      'Sarakawa',
      'Tchaoudjo',
    ],
    'Sokodé': [
      'Centre-ville',
      'Kpangalam',
      'Komah',
      'Didaouré',
      'Tchébébé',
    ],
    'Atakpamé': [
      'Centre-ville',
      'Agbandi',
      'Djama',
      'Saligbé',
    ],
    'Kpalimé': [
      'Centre-ville',
      'Kpadapé',
      'Tomégbé',
      'Hihéatro',
    ],
    'Dapaong': [
      'Centre-ville',
      'Namoni',
      'Sansanné-Mango',
    ],
    'Tsévié': [
      'Centre-ville',
      'Davié',
      'Mission',
    ],
    'Aného': [
      'Centre-ville',
      'Glidji',
      'Adjido',
    ],
  };

  /// Récupère toutes les villes
  static List<String> get allCities => citiesWithNeighborhoods.keys.toList();

  /// Récupère les quartiers d'une ville
  static List<String> getNeighborhoods(String city) {
    return citiesWithNeighborhoods[city] ?? [];
  }

  /// Vérifie si une ville existe
  static bool cityExists(String city) {
    return citiesWithNeighborhoods.containsKey(city);
  }
}
