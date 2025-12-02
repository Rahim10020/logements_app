# Guide de Démarrage Rapide - TogoStay

## 🚀 Démarrage en 5 minutes

### 1. Installation des dépendances

```bash
flutter pub get
```

### 2. Configuration Firebase (Développement)

Pour un démarrage rapide, vous pouvez utiliser ces valeurs temporaires dans `lib/config/firebase_config.dart`:

```dart
// ATTENTION: Ces valeurs sont pour le développement uniquement
// Remplacez-les par vos vraies clés Firebase pour la production

const FirebaseOptions(
  apiKey: 'AIzaSyDemoKey123456789',
  appId: '1:123456789:android:abc123',
  messagingSenderId: '123456789',
  projectId: 'togostay-demo',
  storageBucket: 'togostay-demo.appspot.com',
)
```

### 3. Configuration Appwrite (Développement)

Dans `lib/config/appwrite_config.dart`:

```dart
// Utilisez Appwrite Cloud ou votre instance locale
static const String endpoint = 'https://cloud.appwrite.io/v1';
static const String projectId = 'demo-project-id';
static const String bucketId = 'listing_images';
```

### 4. Lancer l'application

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (si activé)
flutter run -d chrome
```

## 📋 Checklist de Configuration Complète

### Firebase Setup

- [ ] Créer un projet Firebase
- [ ] Activer Authentication (Email + Google)
- [ ] Créer une base Firestore
- [ ] Télécharger `google-services.json` (Android)
- [ ] Télécharger `GoogleService-Info.plist` (iOS)
- [ ] Configurer les règles de sécurité Firestore
- [ ] Mettre à jour `firebase_config.dart` avec vos clés

### Appwrite Setup

- [ ] Créer un projet Appwrite
- [ ] Créer un bucket "listing_images"
- [ ] Configurer les permissions du bucket
- [ ] Mettre à jour `appwrite_config.dart` avec vos clés

### Google Sign-In (Optionnel)

- [ ] Obtenir un Client ID OAuth 2.0
- [ ] Configurer le consentement OAuth
- [ ] Ajouter le Client ID dans Firebase
- [ ] Tester la connexion Google

## 🛠️ Configuration des Plateformes

### Android

#### Fichier: `android/app/build.gradle.kts`

Vérifiez que vous avez:

```kotlin
android {
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
```

#### Fichier: `android/app/src/main/AndroidManifest.xml`

Ajoutez les permissions:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS

#### Fichier: `ios/Runner/Info.plist`

Ajoutez:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>TogoStay a besoin d'accéder à votre localisation pour afficher les annonces à proximité</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>TogoStay a besoin d'accéder à vos photos pour ajouter des images aux annonces</string>

<key>NSCameraUsageDescription</key>
<string>TogoStay a besoin d'accéder à votre caméra pour prendre des photos d'annonces</string>
```

## 📱 Tests Rapides

### Test 1: Connexion sans Backend

L'application peut fonctionner en mode démo même sans Firebase configuré. Certaines fonctionnalités seront limitées.

### Test 2: UI/UX

```bash
# Lancer en mode debug
flutter run --debug

# Hot reload: appuyez sur 'r' dans le terminal
# Hot restart: appuyez sur 'R' dans le terminal
```

### Test 3: Performance

```bash
# Lancer en mode release
flutter run --release
```

## 🎨 Personnalisation Rapide

### Changer les Couleurs

Éditez `lib/core/constants/app_colors.dart`:

```dart
static const Color primary = Color(0xFF7c3aed); // Votre couleur
static const Color brand = Color(0xFFff385c);   // Votre marque
```

### Changer le Nom de l'App

1. **Android**: `android/app/src/main/AndroidManifest.xml`
   ```xml
   <application android:label="VotreNom">
   ```

2. **iOS**: `ios/Runner/Info.plist`
   ```xml
   <key>CFBundleName</key>
   <string>VotreNom</string>
   ```

3. **pubspec.yaml**
   ```yaml
   name: votre_app_name
   description: "Votre description"
   ```

## 🐛 Résolution des Problèmes Courants

### Erreur: "Firebase not initialized"

```bash
# Assurez-vous que Firebase est bien initialisé dans main.dart
# Vérifiez que google-services.json est dans android/app/
```

### Erreur: "Google Sign-In failed"

```bash
# Vérifiez que le SHA-1 est configuré dans Firebase
# Commande pour obtenir le SHA-1:
cd android && ./gradlew signingReport
```

### Erreur: "Pod install failed" (iOS)

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Erreur de compilation Android

```bash
flutter clean
cd android && ./gradlew clean
cd ..
flutter pub get
flutter run
```

## 📚 Ressources Utiles

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Appwrite Flutter Docs](https://appwrite.io/docs/sdks#client)
- [Riverpod Documentation](https://riverpod.dev/)
- [Go Router Package](https://pub.dev/packages/go_router)

## 💡 Conseils Pro

1. **Mode Debug vs Release**: Toujours tester en mode release avant de publier
2. **Hot Reload**: Utilisez 'r' pour un rechargement rapide pendant le développement
3. **DevTools**: Lancez Flutter DevTools pour le debugging avancé
4. **Performance**: Utilisez `const` autant que possible pour améliorer les performances
5. **State Management**: Riverpod invalide automatiquement les providers - utilisez `ref.invalidate()` pour rafraîchir

## 🎯 Prochaines Étapes

Une fois l'app lancée avec succès:

1. ✅ Testez la navigation entre les pages
2. ✅ Vérifiez le thème dark/light
3. ✅ Testez la connexion (même sans backend)
4. 🔲 Configurez Firebase pour la production
5. 🔲 Configurez Appwrite pour les images
6. 🔲 Ajoutez vos propres données de test
7. 🔲 Personnalisez les couleurs et le branding
8. 🔲 Implémentez les fonctionnalités manquantes

## 🤝 Besoin d'Aide?

- **Documentation**: Voir `README_TOGOSTAY.md`
- **Structure**: Voir la section "Structure du Projet"
- **Exemples**: Consultez les fichiers dans `lib/presentation/pages/`

---

Bon développement avec TogoStay! 🚀🏠
