# Guide de Déploiement - TogoStay

## 📦 Préparation pour la Production

### 1. Configuration des Environnements

Créez des fichiers de configuration séparés pour dev et prod:

```dart
// lib/config/env_config.dart
enum Environment { dev, staging, prod }

class EnvConfig {
  static Environment currentEnv = Environment.dev;
  
  static String get firebaseProjectId {
    switch (currentEnv) {
      case Environment.dev:
        return 'togostay-dev';
      case Environment.staging:
        return 'togostay-staging';
      case Environment.prod:
        return 'togostay-prod';
    }
  }
  
  static String get appwriteProjectId {
    switch (currentEnv) {
      case Environment.dev:
        return 'dev-project-id';
      case Environment.staging:
        return 'staging-project-id';
      case Environment.prod:
        return 'prod-project-id';
    }
  }
}
```

### 2. Vérifications Avant Déploiement

#### Checklist Sécurité
- [ ] Supprimer tous les `print()` et logs sensibles
- [ ] Vérifier que les clés API ne sont pas hardcodées
- [ ] Activer ProGuard/R8 pour Android
- [ ] Configurer App Transport Security pour iOS
- [ ] Vérifier les permissions dans AndroidManifest.xml et Info.plist

#### Checklist Performance
- [ ] Optimiser les images (compression, format WebP)
- [ ] Activer le cache des images réseau
- [ ] Minimiser les rebuilds inutiles
- [ ] Utiliser `const` constructors
- [ ] Tester en mode Release

#### Checklist Fonctionnelle
- [ ] Tester toutes les fonctionnalités principales
- [ ] Vérifier la gestion des erreurs
- [ ] Tester hors ligne
- [ ] Vérifier les deeplinks
- [ ] Tester sur différents appareils/tailles d'écran

## 🤖 Déploiement Android

### 1. Configuration du Signing

Créez un keystore:

```bash
keytool -genkey -v -keystore ~/togostay-release.keystore \
  -alias togostay -keyalg RSA -keysize 2048 -validity 10000
```

Créez `android/key.properties`:

```properties
storePassword=VOTRE_STORE_PASSWORD
keyPassword=VOTRE_KEY_PASSWORD
keyAlias=togostay
storeFile=/path/to/togostay-release.keystore
```

Modifiez `android/app/build.gradle.kts`:

```kotlin
android {
    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 2. Build APK

```bash
# APK de production
flutter build apk --release

# APK de debug
flutter build apk --debug

# APK split par ABI (recommandé pour Google Play)
flutter build apk --split-per-abi --release
```

### 3. Build App Bundle (Google Play)

```bash
flutter build appbundle --release
```

Le fichier sera dans: `build/app/outputs/bundle/release/app-release.aab`

### 4. Upload sur Google Play Console

1. Allez sur [Google Play Console](https://play.google.com/console)
2. Créez une nouvelle application
3. Remplissez les informations:
   - Titre: TogoStay
   - Description courte et longue
   - Screenshots (minimum 2 par type d'appareil)
   - Icon 512x512
   - Feature graphic 1024x500
4. Créez une release de production
5. Uploadez l'AAB
6. Remplissez le questionnaire de contenu
7. Définissez le prix et la disponibilité
8. Soumettez pour révision

## 🍎 Déploiement iOS

### 1. Configuration Xcode

Ouvrez `ios/Runner.xcworkspace` dans Xcode:

1. Sélectionnez Runner > Signing & Capabilities
2. Activez "Automatically manage signing"
3. Sélectionnez votre Team
4. Vérifiez le Bundle Identifier: `com.togostay.app`

### 2. Configuration App Store Connect

1. Créez une icône 1024x1024 (sans alpha channel)
2. Préparez les screenshots:
   - iPhone 6.7" (1290x2796)
   - iPhone 6.5" (1242x2688)
   - iPad Pro 12.9" (2048x2732)

### 3. Build pour l'App Store

```bash
# Clean et build
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Ou build IPA directement
flutter build ipa --release
```

### 4. Archive et Upload

**Méthode 1: Via Xcode**

1. Ouvrez `ios/Runner.xcworkspace`
2. Sélectionnez "Any iOS Device"
3. Product > Archive
4. Window > Organizer
5. Sélectionnez l'archive > Distribute App
6. Upload vers App Store Connect

**Méthode 2: Via Command Line**

```bash
# Build IPA
flutter build ipa --release

# Upload avec Transporter
# Téléchargez Transporter depuis Mac App Store
# Ou utilisez xcrun altool
```

### 5. Soumettre pour Révision

1. Allez sur [App Store Connect](https://appstoreconnect.apple.com)
2. Sélectionnez votre app
3. Créez une nouvelle version
4. Remplissez les informations
5. Ajoutez les screenshots
6. Ajoutez la build
7. Soumettez pour révision

## 🌐 Déploiement Web (Optionnel)

```bash
# Build pour le web
flutter build web --release

# Les fichiers seront dans build/web/
```

Déployez sur:
- **Firebase Hosting**:
  ```bash
  firebase init hosting
  firebase deploy
  ```

- **Vercel**:
  ```bash
  vercel --prod
  ```

- **Netlify**: Glissez-déposez le dossier `build/web`

## 🔧 Configuration CI/CD

### GitHub Actions (Exemple)

Créez `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## 📊 Monitoring Post-Déploiement

### Firebase Crashlytics

Ajoutez dans `pubspec.yaml`:

```yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

Configuration dans `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(const TogoStayApp());
}
```

### Firebase Analytics

```yaml
dependencies:
  firebase_analytics: ^10.7.0
```

```dart
final analytics = FirebaseAnalytics.instance;

// Log events
analytics.logEvent(
  name: 'view_listing',
  parameters: {'listing_id': listingId},
);
```

## 🔄 Mises à Jour

### Versioning

Incrémentez dans `pubspec.yaml`:

```yaml
version: 1.0.1+2  # version+buildNumber
```

### Hot Updates (CodePush - Optionnel)

Pour les mises à jour sans passer par les stores:

```yaml
dependencies:
  code_push: ^latest
```

## 📋 Checklist Finale

- [ ] Version incrémentée
- [ ] Changelog mis à jour
- [ ] Tests passés
- [ ] Build de release testée
- [ ] Screenshots à jour
- [ ] Description des stores mise à jour
- [ ] Privacy Policy à jour
- [ ] Terms of Service à jour
- [ ] Clés API de production configurées
- [ ] Firebase configuré
- [ ] Appwrite configuré
- [ ] Monitoring activé
- [ ] Crashlytics configuré
- [ ] Analytics configuré

## 🆘 Problèmes Courants

### Build Failed

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk --release
```

### iOS Archive Failed

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios --release
```

### Upload Rejected

- Vérifier la version/build number
- Vérifier les permissions
- Vérifier les icônes (pas de transparence pour iOS)
- Lire attentivement le message de rejet

---

Bon déploiement! 🚀
