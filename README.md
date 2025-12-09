# 🏠 TogoStay - Application de Location Immobilière

Application mobile Flutter pour la recherche et la gestion de logements au Togo.

## 📱 À propos

TogoStay est une plateforme moderne de location immobilière dédiée au marché togolais. L'application permet aux utilisateurs de :
- 🔍 Rechercher des logements (appartements, villas, studios, chambres)
- ❤️ Sauvegarder leurs annonces favorites
- 📞 Contacter directement les propriétaires
- 🏢 Publier et gérer leurs propres annonces (pour les propriétaires)

## ✨ Fonctionnalités Actuelles

### ✅ Phase 1 - Setup & Configuration (Complétée)
- Architecture des dossiers
- Configuration Firebase (Auth, Firestore, Storage)
- Configuration Appwrite (backup)
- Thème clair/sombre
- Routing avec GoRouter
- Constantes (villes, quartiers du Togo)

### ✅ Phase 2 - Authentification (Complétée)
- Connexion email/password
- Inscription avec validation
- Authentification Google
- Mot de passe oublié
- Sélection de rôle (Chercheur/Propriétaire/Agent)

### ✅ Phase 3 - Core Features (Complétée)
- Liste d'annonces groupées par quartier
- Détails complets d'une annonce
- Système de favoris en temps réel
- Carousel d'images
- Carte OpenStreetMap
- Contact propriétaire (Téléphone, WhatsApp, Email)
- Partage d'annonces
- Filtres rapides par type de propriété

### ⏳ À venir
- Phase 4: Recherche & Filtres avancés
- Phase 5: Dashboard Propriétaire
- Phase 6: Profil Utilisateur
- Phase 7: Notifications & Chat

## 🚀 Installation

### Prérequis
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Un IDE (VSCode, Android Studio, IntelliJ)
- Un compte Firebase
- Un émulateur ou appareil physique

### Installation

1. **Cloner le projet**
```bash
git clone <votre-repo>
cd logements_app
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Firebase**
- Créer un projet Firebase
- Activer Authentication (Email/Password et Google)
- Créer une base Firestore
- Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
- Placer les fichiers dans les dossiers appropriés

4. **Lancer l'application**
```bash
flutter run
```

## 📁 Structure du Projet

```
lib/
├── app.dart                    # Widget racine
├── main.dart                   # Point d'entrée
├── core/                       # Configuration de base
│   ├── config/                 # Router, Firebase, Appwrite
│   ├── constants/              # Couleurs, villes, données
│   ├── theme/                  # Thème clair/sombre
│   └── utils/                  # Utilitaires
├── data/                       # Couche données
│   ├── models/                 # Modèles de données
│   ├── repositories/           # Logique d'accès aux données
│   └── services/               # Services externes
├── features/                   # Fonctionnalités
│   ├── auth/                   # Authentification
│   ├── home/                   # Écran d'accueil
│   ├── saved/                  # Favoris
│   ├── listing_detail/         # Détails annonce
│   ├── dashboard/              # Dashboard propriétaire
│   ├── profile/                # Profil utilisateur
│   └── search/                 # Recherche
└── shared/                     # Composants partagés
    ├── providers/              # Providers globaux
    └── widgets/                # Widgets réutilisables
```

## 🛠️ Technologies

### Frontend
- **Flutter** 3.x - Framework UI
- **Dart** 3.x - Langage

### State Management
- **Provider** - Gestion d'état principale
- **Riverpod** - Thème et preferences

### Backend
- **Firebase Auth** - Authentification
- **Cloud Firestore** - Base de données NoSQL
- **Firebase Storage** - Stockage d'images
- **Appwrite** - Backend alternatif (backup)

### Packages Principaux
- `go_router` - Navigation déclarative
- `firebase_auth` - Authentification Firebase
- `cloud_firestore` - Base de données
- `cached_network_image` - Cache d'images
- `flutter_map` - Cartes OpenStreetMap
- `share_plus` - Partage
- `url_launcher` - Liens externes
- `image_picker` - Sélection d'images

## 📚 Documentation

- **[PHASE1_COMPLETE.md](PHASE1_COMPLETE.md)** - Détails Phase 1
- **[PHASE2_COMPLETE.md](PHASE2_COMPLETE.md)** - Détails Phase 2
- **[PHASE3_COMPLETE.md](PHASE3_COMPLETE.md)** - Détails Phase 3
- **[PHASE3_SUMMARY.md](PHASE3_SUMMARY.md)** - Résumé Phase 3
- **[PHASE3_TESTS.md](PHASE3_TESTS.md)** - Guide de test
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - État global du projet
- **[prompt.md](prompt.md)** - Spécifications complètes

## 🧪 Tests

### Exécuter les tests
```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Analyse de code
flutter analyze

# Vérification Phase 3
./verify_phase3.sh
```

### Tests manuels
Consultez [PHASE3_TESTS.md](PHASE3_TESTS.md) pour les scénarios de test détaillés.

## 🎨 Design

- **Style**: Minimaliste et épuré
- **Couleurs**: Bleu moderne (#2563EB), Vert (#10B981), Orange (#F59E0B)
- **Typographie**: Clear, lisible, hiérarchie bien définie
- **Espacement**: Grid 8dp pour cohérence
- **Composants**: Material Design avec personnalisation

## 📊 Progression

- ✅ Phase 1: Setup & Configuration (100%)
- ✅ Phase 2: Authentification (100%)
- ✅ Phase 3: Core Features (100%)
- ⏳ Phase 4: Recherche & Filtres (0%)
- ⏳ Phase 5: Dashboard Propriétaire (0%)
- ⏳ Phase 6: Profil Utilisateur (0%)
- ⏳ Phase 7: Notifications & Chat (0%)

**Progression globale: 43% (3/7 phases)**

## 🤝 Contribution

Ce projet est en développement actif. Pour contribuer :
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous licence MIT.

## 👨‍💻 Auteur

Développé pour le marché immobilier togolais.

## 🙏 Remerciements

- Flutter Team
- Firebase Team
- OpenStreetMap Contributors
- Communauté Flutter Togo

---

**Dernière mise à jour**: 9 décembre 2024  
**Version**: 0.3.0 (Phase 3 complétée)

Pour toute question, consultez la [documentation](PROJECT_STATUS.md) ou les fichiers de phase.

