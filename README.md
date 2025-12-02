# TogoStay - Application Mobile Flutter

![TogoStay Logo](https://via.placeholder.com/800x200/7c3aed/ffffff?text=TogoStay)

## 🏠 Description

TogoStay est une application mobile Flutter pour iOS et Android permettant de rechercher et proposer des logements au Togo. L'application reprend les fonctionnalités de la version web avec une expérience mobile optimisée.

## ✨ Fonctionnalités

### 🔐 Authentification
- Inscription / Connexion par email et mot de passe
- Connexion Google OAuth
- Réinitialisation du mot de passe
- Sélection de rôle (Locataire / Propriétaire / Les deux)
- Persistance de session

### 🏘️ Découverte
- Page d'accueil avec grid d'annonces
- Recherche par ville, quartier
- Filtres avancés (prix, surface, type, commodités)
- Groupement par quartiers
- Pull-to-refresh
- Gestion des favoris

### 📝 Annonces
- Détail d'annonce avec carousel d'images
- Informations complètes (prix, surface, chambres, etc.)
- Carte de localisation (OpenStreetMap)
- Partage d'annonce
- Contact propriétaire

### 👤 Dashboard Propriétaire
- Statistiques (vues, favoris)
- Liste des annonces avec actions
- Création/édition d'annonce en 6 étapes
- Upload d'images via Appwrite
- Gestion du statut des annonces

### ⚙️ Profil & Paramètres
- Édition du profil
- Photo de profil
- Changement de rôle
- Mode sombre / clair
- Déconnexion

## 🛠️ Stack Technique

- **Framework**: Flutter 3.24+
- **State Management**: Riverpod
- **Backend**: Firebase (Auth + Firestore)
- **Storage**: Appwrite
- **Navigation**: go_router
- **Maps**: flutter_map + OpenStreetMap
- **Local Storage**: shared_preferences

## 📦 Dépendances Principales

```yaml
# State Management
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.5

# Firebase
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4

# Appwrite
appwrite: ^12.0.3

# Navigation
go_router: ^14.6.1

# Maps
flutter_map: ^7.0.2
geolocator: ^13.0.2
```

## 🚀 Installation et Configuration

### 1. Prérequis

- Flutter SDK 3.5.4 ou supérieur
- Dart SDK 3.5.4 ou supérieur
- Android Studio / Xcode pour le développement mobile
- Un projet Firebase
- Un projet Appwrite

### 2. Cloner le projet

```bash
git clone https://github.com/votre-username/togostay-mobile.git
cd togostay-mobile
```

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Configuration Firebase

#### a. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet "TogoStay"
3. Activez Authentication (Email/Password + Google)
4. Créez une base Firestore

#### b. Configurer Android

1. Téléchargez `google-services.json`
2. Placez-le dans `android/app/`
3. Modifiez `android/build.gradle.kts` et `android/app/build.gradle.kts`

#### c. Configurer iOS

1. Téléchargez `GoogleService-Info.plist`
2. Placez-le dans `ios/Runner/`
3. Ouvrez `ios/Runner.xcworkspace` dans Xcode

#### d. Mettre à jour les clés Firebase

Éditez `lib/config/firebase_config.dart`:

```dart
FirebaseOptions(
  apiKey: 'VOTRE_API_KEY',
  appId: 'VOTRE_APP_ID',
  messagingSenderId: 'VOTRE_SENDER_ID',
  projectId: 'togostay',
  storageBucket: 'togostay.appspot.com',
  androidClientId: 'VOTRE_ANDROID_CLIENT_ID',
  iosClientId: 'VOTRE_IOS_CLIENT_ID',
  iosBundleId: 'com.togostay.app',
)
```

### 5. Configuration Appwrite

1. Créez un compte sur [Appwrite Cloud](https://cloud.appwrite.io/)
2. Créez un nouveau projet
3. Créez un bucket "listing_images" pour les images

Éditez `lib/config/appwrite_config.dart`:

```dart
static const String projectId = 'VOTRE_PROJECT_ID';
static const String bucketId = 'listing_images';
```

### 6. Structure Firestore

Créez les collections suivantes dans Firestore:

#### Collection `users`
```json
{
  "email": "string",
  "displayName": "string",
  "photoUrl": "string",
  "phoneNumber": "string",
  "role": "string", // tenant, owner, both
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Sous-collection `favorites`:
```json
{
  "addedAt": "timestamp"
}
```

#### Collection `listings`
```json
{
  "ownerId": "string",
  "title": "string",
  "description": "string",
  "type": "string", // apartment, house, studio, villa, room
  "price": "number",
  "city": "string",
  "neighborhood": "string",
  "address": "string",
  "location": "geopoint",
  "area": "number",
  "bedrooms": "number",
  "bathrooms": "number",
  "amenities": "array",
  "images": "array",
  "status": "string", // active, inactive, rented
  "views": "number",
  "favoritesCount": "number",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 7. Règles de sécurité Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      match /favorites/{listingId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Listings
    match /listings/{listingId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
  }
}
```

### 8. Lancer l'application

#### Android

```bash
flutter run -d android
```

#### iOS

```bash
flutter run -d ios
```

#### Debug Mode

```bash
flutter run --debug
```

#### Release Mode

```bash
flutter run --release
```

## 🎨 Palette de Couleurs

### Principales
- **Primary**: `#7c3aed` (Violet)
- **Secondary**: `#f97316` (Orange)
- **Accent**: `#0ea5e9` (Bleu)
- **Pink**: `#ec4899`
- **Brand**: `#ff385c` (Airbnb-like)

### Dark Mode
- **Background**: `#18122B`
- **Card**: `#231942`
- **Border**: `#393053`
- **Text**: `#f3f4f6`

### Light Mode
- **Background**: `#f8fafc`
- **Card**: `#fff1fa`
- **Border**: `#e0e7ef`
- **Text**: `#18122B`

## 📁 Structure du Projet

```
lib/
├── config/
│   ├── firebase_config.dart
│   ├── appwrite_config.dart
│   └── router_config.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   └── app_strings.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── format_utils.dart
│       └── validators.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── listing_model.dart
│   │   └── search_filter.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── listing_repository.dart
│       └── favorite_repository.dart
├── presentation/
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   └── role_selection_page.dart
│   │   ├── home/
│   │   │   └── home_page.dart
│   │   └── main_page.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── listing_provider.dart
│   │   ├── favorite_provider.dart
│   │   └── theme_provider.dart
│   └── widgets/
│       ├── listing_card.dart
│       ├── custom_buttons.dart
│       └── custom_text_field.dart
└── main.dart
```

## 🔧 Commandes Utiles

### Générer le code (Riverpod)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Nettoyer le projet

```bash
flutter clean
flutter pub get
```

### Analyser le code

```bash
flutter analyze
```

### Formater le code

```bash
flutter format lib/
```

### Créer un build

#### Android APK

```bash
flutter build apk --release
```

#### Android App Bundle

```bash
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

## 🧪 Tests

```bash
# Tous les tests
flutter test

# Tests avec coverage
flutter test --coverage

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 📱 Plateformes Supportées

- ✅ Android (API 21+)
- ✅ iOS (13.0+)
- 🚧 Web (en développement)

## 🤝 Contribution

Les contributions sont les bienvenues! Veuillez suivre ces étapes:

1. Fork le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add: AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 License

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Auteur

**Votre Nom**
- GitHub: [@votre-username](https://github.com/Rahim10020)
- Email: votre@email.com

## 🙏 Remerciements

- Design inspiré par Airbnb
- Icons par Material Design
- Maps par OpenStreetMap
- Backend par Firebase & Appwrite

---

**TogoStay** - Trouvez votre chez-vous au Togo 🏠
