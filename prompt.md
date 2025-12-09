# Prompt pour Développement Application TogoStay - Flutter

## 🎯 Objectif
Créer une application mobile Flutter complète pour la location immobilière au Togo, avec un design **minimaliste et clean**. L'application permettra aux utilisateurs de chercher des logements et aux propriétaires de publier leurs annonces.

---

## 🎨 Direction Design - TRÈS IMPORTANT

### Philosophie de Design
- **Style**: Minimaliste, épuré, moderne
- **Espaces blancs**: Généreux, aéré
- **Typographie**: Simple, hiérarchie claire (titres en gras, corps en regular)
- **Couleurs**: Palette sobre et professionnelle
    - Couleur primaire: #2563EB (bleu moderne)
    - Couleur secondaire: #10B981 (vert pour succès)
    - Couleur accent: #F59E0B (orange pour actions importantes)
    - Neutre: Gris (#6B7280, #9CA3AF, #E5E7EB, #F9FAFB)
    - Texte: #111827 (dark mode: #F9FAFB)
- **Coins arrondis**: 12-16px pour les cartes, 8px pour les boutons
- **Ombres**: Subtiles et douces (elevation 2-4 maximum)
- **Icônes**: Material Icons ou Lucide Icons (simples et fines)

### Composants UI
- **Cards**: Fond blanc, ombre légère, padding généreux
- **Boutons**:
    - Primaires: Remplis avec couleur primaire
    - Secondaires: Outline simple
    - Ghost: Texte uniquement
    - Height: 48-52px
- **Inputs**: Bordure fine, focus subtil, placeholder gris clair
- **Bottom Navigation**: 5 items max, icônes + labels
- **AppBar**: Minimal, titre centré ou à gauche, actions à droite

---

## 🏗️ Architecture et Structure du Projet

### Structure des Dossiers
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── firebase_config.dart
│   │   └── appwrite_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_assets.dart
│   │   └── cities_data.dart (villes et quartiers du Togo)
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       └── helpers.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── listing_model.dart
│   │   ├── saved_listing_model.dart
│   │   └── message_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── listing_repository.dart
│   │   ├── user_repository.dart
│   │   └── storage_repository.dart
│   └── services/
│       ├── firebase_service.dart
│       ├── appwrite_service.dart
│       └── local_storage_service.dart
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── role_selection_screen.dart
│   │   ├── widgets/
│   │   │   ├── auth_button.dart
│   │   │   ├── auth_text_field.dart
│   │   │   └── social_auth_button.dart
│   │   └── providers/
│   │       └── auth_provider.dart
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   ├── widgets/
│   │   │   ├── listing_card.dart
│   │   │   ├── search_bar_widget.dart
│   │   │   ├── neighborhood_section.dart
│   │   │   └── hero_section.dart
│   │   └── providers/
│   │       └── home_provider.dart
│   ├── listing_detail/
│   │   ├── screens/
│   │   │   └── listing_detail_screen.dart
│   │   ├── widgets/
│   │   │   ├── image_carousel.dart
│   │   │   ├── amenities_grid.dart
│   │   │   ├── map_widget.dart
│   │   │   └── owner_card.dart
│   │   └── providers/
│   │       └── listing_detail_provider.dart
│   ├── search/
│   │   ├── screens/
│   │   │   └── search_screen.dart
│   │   ├── widgets/
│   │   │   ├── filter_chip_widget.dart
│   │   │   ├── price_range_slider.dart
│   │   │   └── amenities_filter.dart
│   │   └── providers/
│   │       └── search_provider.dart
│   ├── saved/
│   │   ├── screens/
│   │   │   └── saved_listings_screen.dart
│   │   └── providers/
│   │       └── saved_provider.dart
│   ├── dashboard/
│   │   ├── screens/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── add_listing_screen.dart
│   │   │   ├── edit_listing_screen.dart
│   │   │   └── messages_screen.dart
│   │   ├── widgets/
│   │   │   ├── stats_card.dart
│   │   │   ├── listing_item_owner.dart
│   │   │   ├── message_item.dart
│   │   │   └── step_indicator.dart
│   │   └── providers/
│   │       └── dashboard_provider.dart
│   └── profile/
│       ├── screens/
│       │   ├── profile_screen.dart
│       │   └── edit_profile_screen.dart
│       ├── widgets/
│       │   ├── profile_avatar.dart
│       │   └── setting_item.dart
│       └── providers/
│           └── profile_provider.dart
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_indicator.dart
    │   ├── error_widget.dart
    │   ├── empty_state.dart
    │   └── bottom_nav_bar.dart
    └── providers/
        └── theme_provider.dart
```

---

## 🔥 Configuration Firebase

### Collection Firestore: `listings`
```json
{
  "id": "string (auto-generated)",
  "userId": "string",
  "city": "string",
  "neighborhood": "string",
  "propertyType": "string (apartment, house, studio, etc.)",
  "bedrooms": "number",
  "bathrooms": "number",
  "area": "number",
  "monthlyPrice": "number",
  "description": "string",
  "isRented": "boolean",
  "imageIds": ["string"],
  "latitude": "number (nullable)",
  "longitude": "number (nullable)",
  "address": "string (nullable)",
  
  "furnished": "boolean",
  "airConditioning": "boolean",
  "wifi": "boolean",
  "parking": "boolean",
  "equippedKitchen": "boolean",
  "balcony": "boolean",
  "generator": "boolean",
  "waterTank": "boolean",
  "borehole": "boolean",
  "security": "boolean",
  "fence": "boolean",
  "tiledFloor": "boolean",
  "ceilingFan": "boolean",
  "individualElectricMeter": "boolean",
  "individualWaterMeter": "boolean",
  
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "favoritesCount": "number"
}
```

### Collection Firestore: `users`
```json
{
  "id": "string (auto-generated)",
  "uid": "string (Firebase Auth UID)",
  "email": "string",
  "displayName": "string",
  "role": "string (tenant, owner, both)",
  "city": "string",
  "phone": "string",
  "photoURL": "string",
  "createdAt": "Timestamp"
}
```

### Collection Firestore: `saved_listings`
```json
{
  "id": "string (auto-generated)",
  "userId": "string",
  "listingId": "string",
  "savedAt": "Timestamp"
}
```

### Collection Firestore: `messages`
```json
{
  "id": "string (auto-generated)",
  "listingId": "string",
  "senderId": "string",
  "recipientId": "string",
  "message": "string",
  "isRead": "boolean",
  "createdAt": "Timestamp"
}
```

---

## 🌍 Données Géographiques (Togo)

### Fichier: `cities_data.dart`
```dart
class TogoLocations {
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
    'Tsévié': [
      'Centre-ville Tsévié',
    ],
    'Aného': [
      'Centre-ville Aného',
    ],
    'Dapaong': [
      'Centre-ville Dapaong',
    ],
  };

  static const List<String> propertyTypes = [
    'Appartement',
    'Maison',
    'Studio',
    'Villa',
    'Duplex',
    'Chambre meublée',
    'Bureau',
    'Magasin',
    'Entrepôt',
    'Terrain',
    'Immeuble',
    'Résidence',
    'Loft',
  ];
}
```

---

## 📱 Fonctionnalités Détaillées

### 1. Authentication Flow
**Écrans**: Login, Register, Role Selection, Forgot Password

**Login Screen**:
- Logo TogoStay en haut (centré)
- TextField Email (avec validation)
- TextField Password (avec icône show/hide)
- Lien "Mot de passe oublié?" (texte petit, gris)
- Bouton "Se connecter" (pleine largeur, primaire)
- Divider "ou continuer avec"
- 2 boutons sociaux (Google, Facebook) avec icônes
- Lien "Pas de compte? S'inscrire" en bas

**Register Screen**:
- Form avec champs: Email, Nom complet, Téléphone, Ville (dropdown), Password, Confirm Password
- Validation en temps réel (email format, password strength, etc.)
- Bouton "S'inscrire"
- Lien retour login

**Role Selection**:
- 3 grandes cartes verticales cliquables:
    1. "Je cherche un logement" (Locataire) - icône search
    2. "Je loue des biens" (Propriétaire) - icône home
    3. "Les deux" - icône both
- Chaque carte avec icône, titre, description courte
- Bouton "Continuer" en bas (disabled jusqu'à sélection)

**Providers nécessaires**:
```dart
class AuthProvider extends ChangeNotifier {
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;
  
  Future<void> signIn(String email, String password) async {}
  Future<void> signUp(String email, String password, String name, String phone, String city) async {}
  Future<void> signInWithGoogle() async {}
  Future<void> signInWithFacebook() async {}
  Future<void> resetPassword(String email) async {}
  Future<void> signOut() async {}
  Future<void> updateUserRole(String role) async {}
}
```

---

### 2. Home Screen
**Layout**:
- AppBar:
    - Logo TogoStay (gauche)
    - Icône Search (droite)
    - Icône Favorites avec badge count (droite)
    - Icône Menu (droite)
- Hero Section:
    - Titre: "Trouvez votre chez-vous au Togo"
    - Sous-titre: "Des milliers de logements disponibles"
    - Barre de recherche avec icon et placeholder "Rechercher une ville, quartier..."
- Filtres rapides (chips horizontaux scrollables):
    - "Tous", "Appartement", "Maison", "Studio", "Villa"
- Section "Annonces par quartier":
    - Titre quartier (ex: "Tokoin - 12 annonces")
    - Grid 2 colonnes d'annonces
    - Espacement de 16px
- Pull-to-refresh
- Bottom Navigation Bar (5 items): Home, Search, Saved, Dashboard, Profile

**Listing Card** (composant réutilisable):
```dart
Widget ListingCard({
  required ListingModel listing,
  required VoidCallback onTap,
  required VoidCallback onFavorite,
  required bool isFavorite,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(...)], // ombre légère
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image avec overlay type + ville
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(...),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${listing.propertyType} • ${listing.city}'),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: onFavorite,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(listing.neighborhood, style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 4),
              Text(
                '${listing.monthlyPrice.toStringAsFixed(0)} FCFA/mois',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.bed, size: 16),
                  SizedBox(width: 4),
                  Text('${listing.bedrooms}'),
                  SizedBox(width: 12),
                  Icon(Icons.bathtub, size: 16),
                  SizedBox(width: 4),
                  Text('${listing.bathrooms}'),
                  SizedBox(width: 12),
                  Icon(Icons.square_foot, size: 16),
                  SizedBox(width: 4),
                  Text('${listing.area}m²'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

**Provider**:
```dart
class HomeProvider extends ChangeNotifier {
  List<ListingModel> listings = [];
  Map<String, List<ListingModel>> listingsByNeighborhood = {};
  bool isLoading = true;
  String? errorMessage;
  
  Future<void> fetchListings() async {}
  void groupListingsByNeighborhood() {}
  Future<void> refreshListings() async {}
}
```

---

### 3. Listing Detail Screen
**Layout**:
- AppBar transparent avec boutons: Back, Share, Favorite
- Image Carousel (swipeable, indicateurs de position)
- Bouton "Voir toutes les photos (X)" en overlay
- Section Infos principales:
    - Type de bien (chip)
    - Prix mensuel (grand, gras)
    - Prix/m² (petit, gris)
    - Row avec icônes: chambres, sdb, surface
    - Adresse complète
- Section Description (expandable si > 3 lignes)
- Section Commodités:
    - Grid 2 colonnes avec icônes + labels
    - Uniquement les commodités = true
- Section Carte (hauteur fixe 200px):
    - Affichage Leaflet/OpenStreetMap
    - Marker sur location
- Section Propriétaire:
    - Card avec photo, nom, téléphone, email
    - Bouton "Contacter le propriétaire" (ouvre dialog WhatsApp/Tel/Email)
- Floating Action Button "Favoris"

**Widgets**:
```dart
class ImageCarousel extends StatefulWidget {}
class AmenitiesGrid extends StatelessWidget {}
class MapWidget extends StatelessWidget {} // avec flutter_map
class OwnerCard extends StatelessWidget {}
```

---

### 4. Search & Filter Screen
**Layout**:
- AppBar avec TextField de recherche
- Liste déroulante des filtres:
    - Type de bien (chips multi-select)
    - Plage de prix (RangeSlider avec labels min-max)
    - Surface min/max (TextFields)
    - Ville (dropdown)
    - Quartier (dropdown filtré par ville)
    - Commodités (checkboxes en grid)
- Bouton "Appliquer" (sticky bottom)
- Bouton "Réinitialiser" (outline)
- Résultats affichés en liste ou grid
- Options de tri: "Prix croissant", "Prix décroissant", "Plus récent", "Pertinence"

**Provider**:
```dart
class SearchProvider extends ChangeNotifier {
  String searchQuery = '';
  List<String> selectedPropertyTypes = [];
  RangeValues priceRange = RangeValues(0, 1000000);
  double? minArea;
  double? maxArea;
  String? selectedCity;
  String? selectedNeighborhood;
  Map<String, bool> selectedAmenities = {};
  
  List<ListingModel> filteredListings = [];
  
  void updateSearch(String query) {}
  void applyFilters() {}
  void resetFilters() {}
  Future<void> searchListings() async {}
}
```

---

### 5. Saved Listings Screen
**Layout**:
- AppBar "Mes Favoris" + compteur
- Si vide: EmptyState avec icône, message, bouton "Découvrir des annonces"
- Sinon: Liste des annonces favorites (même card que home)
- Swipe pour supprimer (avec confirmation)
- Real-time sync avec Firestore

**Provider**:
```dart
class SavedProvider extends ChangeNotifier {
  List<ListingModel> savedListings = [];
  bool isLoading = true;
  
  Stream<List<ListingModel>> watchSavedListings(String userId) {}
  Future<void> addToSaved(String userId, String listingId) async {}
  Future<void> removeFromSaved(String userId, String listingId) async {}
  bool isSaved(String listingId) {}
}
```

---

### 6. Dashboard Screen (Owner)
**Protection**: Nécessite role = "owner" ou "both"

**Layout**:
- Tabs: "Mes Annonces", "Louées", "Messages"
- Stats Overview (cards horizontales):
    - Total annonces
    - Annonces louées
    - Annonces disponibles
    - Messages non lus
- Liste des annonces:
    - Card horizontale avec image, titre, prix, statut
    - Boutons actions: Modifier, Supprimer, Toggle statut (Loué/Disponible)
    - Badge "Disponible" (vert) ou "Loué" (orange)
    - Compteur favoris
- Floating Action Button "+" pour ajouter annonce
- Messages: Liste avec avatar, nom, preview message, date

**Provider**:
```dart
class DashboardProvider extends ChangeNotifier {
  List<ListingModel> myListings = [];
  List<ListingModel> rentedListings = [];
  List<MessageModel> messages = [];
  int totalListings = 0;
  int availableListings = 0;
  int unreadMessages = 0;
  
  Future<void> fetchMyListings(String userId) async {}
  Future<void> deleteListing(String listingId) async {}
  Future<void> toggleRentedStatus(String listingId, bool isRented) async {}
  Future<void> fetchMessages(String userId) async {}
}
```

---

### 7. Add/Edit Listing Screen (Multi-step)
**Wizard avec 6 étapes**:

**Step Indicator** (en haut):
```dart
Row(
  children: [
    for (int i = 0; i < 6; i++)
      Expanded(
        child: Container(
          height: 4,
          color: currentStep >= i ? primaryColor : Colors.grey[300],
        ),
      ),
  ],
)
```

**Étape 1 - Infos de base**:
- Type de bien (dropdown)
- Chambres (stepper -/+)
- Salles de bain (stepper -/+)
- Surface m² (TextField number)
- Ville (dropdown)
- Quartier (dropdown filtré)
- Prix mensuel (TextField avec suffix "FCFA")
- Adresse (TextField optionnel)

**Étape 2 - Commodités**:
- Grid de checkboxes (2 colonnes)
- Toutes les commodités listées
- Icons à côté des labels

**Étape 3 - Description**:
- TextField multiligne (max 500 caractères)
- Compteur de caractères
- Suggestions rapides (boutons):
    - "Bien situé dans un quartier calme"
    - "Proche des commodités"
    - "Idéal pour familles"
    - etc.

**Étape 4 - Photos**:
- Grid d'aperçus (3 colonnes)
- Bouton "Ajouter des photos" (max 10)
- Photo principale marquée (étoile)
- Boutons supprimer/réorganiser
- Progress indicator pendant upload Appwrite
- Compresser images avant upload (max 2MB)

**Étape 5 - Localisation**:
- Carte interactive (flutter_map)
- Bouton "Utiliser ma position actuelle" (GPS)
- Ou déplacer marker manuellement
- Affichage coordonnées (lat, lng)
- Toggle "Localisation exacte" vs "Approximative"

**Étape 6 - Récapitulatif**:
- Card pour chaque section:
    - Infos de base
    - Commodités (liste)
    - Description
    - Photos (carousel miniature)
    - Localisation (carte miniature)
- Boutons "Modifier" pour chaque section (retour à étape)
- Calcul automatique prix/m²
- Bouton final "Publier l'annonce" (ou "Mettre à jour")

**Navigation entre étapes**:
```dart
class AddListingProvider extends ChangeNotifier {
  int currentStep = 0;
  ListingModel draft = ListingModel(); // draft temporaire
  
  void nextStep() {
    if (validateCurrentStep()) {
      currentStep++;
      notifyListeners();
    }
  }
  
  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }
  
  void goToStep(int step) {
    currentStep = step;
    notifyListeners();
  }
  
  bool validateCurrentStep() {
    // Validation selon l'étape
  }
  
  Future<void> submitListing() async {
    // 1. Upload images vers Appwrite
    // 2. Créer document Firestore
    // 3. Rediriger vers Dashboard
  }
}
```

---

### 8. Profile Screen
**Layout**:
- Header avec photo de profil (grande, circulaire)
- Bouton "Modifier la photo"
- Infos affichées:
    - Nom
    - Email
    - Téléphone
    - Ville
    - Rôle (chip coloré)
- Bouton "Modifier le profil"
- Section Paramètres:
    - Toggle "Mode sombre"
    - Lien "Changer de rôle"
    - Lien "Politique de confidentialité"
    - Lien "À propos"
    - Version de l'app
- Bouton "Se déconnecter" (rouge, en bas)

**Edit Profile Screen**:
- Form avec champs éditables
- Upload/Change photo
- Validation
- Bouton "Enregistrer"

---

## 🎯 Composants Partagés Essentiels

### CustomButton
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : (color ?? primaryColor),
        foregroundColor: isOutlined ? primaryColor : Colors.white,
        side: isOutlined ? BorderSide(color: primaryColor) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(double.infinity, 50),
        elevation: isOutlined ? 0 : 2,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading 
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
```

### CustomTextField
```dart
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLines;
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
```

### EmptyState
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            if (buttonText != null) ...[
              SizedBox(height: 24),
              CustomButton(text: buttonText!, onPressed: onButtonPressed!),
            ],
          ],
        ),
      ),
    );
  }
}
```

### LoadingIndicator
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(message!, style: TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
```

---

## 🔐 Sécurité et Permissions

### Permission Handler
```dart
// Dans main.dart ou app startup
Future<void> requestPermissions() async {
  await Permission.location.request();
  await Permission.photos.request();
  await Permission.camera.request();
}
```

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /listings/{listingId} {
      allow read: if true; // Public
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /saved_listings/{savedId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    match /messages/{messageId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || request.auth.uid == resource.data.recipientId);
      allow create: if request.auth != null;
    }
  }
}
```

---

## 🎨 Thème et Styles

### app_theme.dart
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF10B981),
      tertiary: Color(0xFFF59E0B),
      surface: Colors.white,
      background: Color(0xFFF9FAFB),
      error: Color(0xFFEF4444),
    ),
    scaffoldBackgroundColor: Color(0xFFF9FAFB),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111827),
      iconTheme: IconThemeData(color: Color(0xFF111827)),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF374151)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF10B981),
      tertiary: Color(0xFFF59E0B),
      surface: Color(0xFF1F2937),
      background: Color(0xFF111827),
      error: Color(0xFFEF4444),
    ),
    scaffoldBackgroundColor: Color(0xFF111827),
    // ... suite du dark theme
  );
}
```

---

## 🚀 Navigation avec GoRouter

### app_router.dart
```dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.currentUser != null;
    final isOnAuthPage = state.matchedLocation.startsWith('/auth');
    
    if (!isLoggedIn && !isOnAuthPage) {
      return '/auth/login';
    }
    
    if (isLoggedIn && isOnAuthPage) {
      return '/';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => MainScreen(), // avec bottom nav
      routes: [
        GoRoute(
          path: 'listing/:id',
          builder: (context, state) => ListingDetailScreen(
            listingId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: 'register',
          builder: (context, state) => RegisterScreen(),
        ),
        GoRoute(
          path: 'role-selection',
          builder: (context, state) => RoleSelectionScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardScreen(),
      routes: [
        GoRoute(
          path: 'add-listing',
          builder: (context, state) => AddListingScreen(),
        ),
        GoRoute(
          path: 'edit-listing/:id',
          builder: (context, state) => EditListingScreen(
            listingId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => EditProfileScreen(),
        ),
      ],
    ),
  ],
);
```

---

## ✅ Checklist d'Implémentation

### Phase 1 - Setup (Priorité Haute)
- [ ] Créer projet Flutter
- [ ] Installer toutes les dépendances
- [ ] Configurer Firebase (Auth, Firestore)
- [ ] Configurer Appwrite (Storage)
- [ ] Créer structure de dossiers
- [ ] Implémenter thèmes (light/dark)
- [ ] Setup navigation (GoRouter)
- [ ] Créer fichiers constants (couleurs, strings, cities_data)

### Phase 2 - Authentification (Priorité Haute)
- [ ] Créer modèle User
- [ ] Implémenter AuthProvider
- [ ] Écran Login (UI + logique)
- [ ] Écran Register (UI + logique)
- [ ] Écran Role Selection
- [ ] Authentification Google
- [ ] Authentification Facebook
- [ ] Forgot Password
- [ ] Persistance session (SharedPreferences)
- [ ] Redirection automatique selon auth state

### Phase 3 - Core Features (Priorité Haute)
- [ ] Créer modèle Listing
- [ ] Implémenter ListingRepository
- [ ] Home Screen (UI + provider)
- [ ] Listing Card component
- [ ] Listing Detail Screen (complet)
- [ ] Image Carousel
- [ ] Map Widget (flutter_map)
- [ ] Favoris (UI + provider + Firestore sync)
- [ ] Saved Listings Screen

### Phase 4 - Recherche et Filtres (Priorité Moyenne)
- [ ] Search Screen UI
- [ ] Filtres avancés (tous les types)
- [ ] Provider pour recherche/filtres
- [ ] Sauvegarde des filtres (SharedPreferences)
- [ ] Tri des résultats

### Phase 5 - Dashboard Propriétaire (Priorité Moyenne)
- [ ] Dashboard Screen (stats + liste)
- [ ] Protection par rôle
- [ ] Liste mes annonces
- [ ] Toggle statut loué/disponible
- [ ] Supprimer annonce (avec confirmation)
- [ ] Messages/Notifications

### Phase 6 - Création d'Annonce (Priorité Haute)
- [ ] Wizard multi-étapes (structure)
- [ ] Étape 1: Infos de base
- [ ] Étape 2: Commodités
- [ ] Étape 3: Description
- [ ] Étape 4: Upload images (vers Appwrite)
- [ ] Étape 5: Carte + GPS
- [ ] Étape 6: Récapitulatif
- [ ] Provider AddListing
- [ ] Validation à chaque étape
- [ ] Soumission finale vers Firestore

### Phase 7 - Profil et Paramètres (Priorité Moyenne)
- [ ] Profile Screen
- [ ] Edit Profile
- [ ] Upload/Change photo de profil
- [ ] Toggle dark mode (avec persistance)
- [ ] Déconnexion

### Phase 8 - Polish et Optimisations (Priorité Basse)
- [ ] Shimmer loading states
- [ ] Empty states partout
- [ ] Error handling avec messages clairs
- [ ] Pull-to-refresh sur listes
- [ ] Compression images avant upload
- [ ] Cache images (CachedNetworkImage)
- [ ] Offline support basique
- [ ] Animations et transitions
- [ ] Tester sur iOS et Android
- [ ] Fix warnings/errors
- [ ] Performance optimizations

### Phase 9 - Features Additionnelles (Optionnel)
- [ ] Partage d'annonce
- [ ] Notifications push (FCM)
- [ ] Chat en temps réel
- [ ] Historique de recherche
- [ ] Suggestions personnalisées
- [ ] Analytics

---

## 📝 Notes Importantes

### Style de Code
- Utiliser `const` partout où c'est possible
- Commentaires en français pour les sections importantes
- Nommer les variables de façon explicite
- Éviter les fichiers > 300 lignes (découper)
- Utiliser `final` pour les variables non réassignées

### Performance
- Utiliser `ListView.builder` pour grandes listes
- Cacher les images avec `CachedNetworkImage`
- Éviter les `setState()` inutiles
- Utiliser `const` constructors
- Lazy load les données

### Tests
- Tester sur émulateur Android ET iOS
- Tester en mode release (pas que debug)
- Vérifier les permissions (GPS, Photos, Camera)
- Tester avec/sans connexion internet
- Tester dark mode

### Priorités Design
1. **Simplicité avant tout** - Éviter les animations excessives
2. **Lisibilité** - Espacements généreux, typographie claire
3. **Cohérence** - Même style partout (boutons, cards, inputs)
4. **Performance** - App fluide, pas de lag
5. **Accessibilité** - Contraste suffisant, tailles de texte lisibles

---

## 🎯 Objectif Final

Une application Flutter **minimaliste et clean** pour la location immobilière au Togo, avec:
- Interface épurée et moderne
- Navigation fluide et intuitive
- Authentification complète (email + OAuth)
- CRUD listings complet (avec wizard multi-étapes)
- Recherche et filtres avancés
- Favoris synchronisés en temps réel
- Dashboard propriétaire fonctionnel
- Upload d'images vers Appwrite
- Cartes interactives
- Dark mode
- Design responsive (mobile-first)

**Commence par la Phase 1 (Setup), puis avance progressivement en suivant l'ordre des phases. N'oublie pas: le design doit rester simple, épuré et professionnel à chaque étape.**

Bon courage! 🚀