# 📋 TODO - TogoStay

Liste des fonctionnalités à implémenter pour compléter l'application.

## 🔴 Priorité Haute (Fonctionnalités Essentielles)

### 1. Page Détail d'Annonce ⏱️ ~4h
**Fichier**: `lib/presentation/pages/listing/listing_detail_page.dart`

- [ ] Layout avec ScrollView
- [ ] Carousel d'images (carousel_slider)
- [ ] Informations principales (prix, type, surface)
- [ ] Section description
- [ ] Liste des commodités avec icônes
- [ ] Carte avec localisation (flutter_map + OSM)
- [ ] Informations propriétaire
- [ ] Boutons: Favoris, Partager, Contacter
- [ ] Incrémentation du compteur de vues

**Dépendances à utiliser**:
```dart
carousel_slider: ^5.0.0
flutter_map: ^7.0.2
url_launcher: ^6.3.1  // Pour appeler/email
share_plus: ^10.1.1   // Pour partager
```

### 2. Page Recherche avec Filtres ⏱️ ~3h
**Fichier**: `lib/presentation/pages/search/search_page.dart`

- [ ] Barre de recherche avec autocomplétion
- [ ] Filtres par ville (dropdown)
- [ ] Filtres par quartier (dropdown dépendant de la ville)
- [ ] Filtres par type de logement (chips)
- [ ] Slider pour prix (min-max)
- [ ] Slider pour surface (min-max)
- [ ] Nombre de chambres/salles de bain (stepper)
- [ ] Sélection des commodités (checkboxes)
- [ ] Bouton "Réinitialiser"
- [ ] Bouton "Appliquer"
- [ ] Affichage des résultats en temps réel
- [ ] Sauvegarde des filtres dans SharedPreferences

**Widgets à créer**:
- `FilterSection` widget
- `PriceRangeSlider` widget
- `AmenityCheckboxList` widget

### 3. Formulaire Ajout/Édition Annonce (6 Étapes) ⏱️ ~8h
**Fichier**: `lib/presentation/pages/listing/add_listing_page.dart`

#### Étape 1: Informations Principales
- [ ] Titre de l'annonce
- [ ] Type de logement (dropdown)
- [ ] Prix mensuel
- [ ] Surface (m²)
- [ ] Nombre de chambres
- [ ] Nombre de salles de bain

#### Étape 2: Commodités
- [ ] Liste checkboxes des 20 commodités
- [ ] Groupées par catégorie
- [ ] Sélection multiple

#### Étape 3: Description
- [ ] TextField multiligne
- [ ] Compteur de caractères
- [ ] Preview en temps réel

#### Étape 4: Photos
- [ ] Upload jusqu'à 10 images
- [ ] Image picker (galerie + caméra)
- [ ] Crop images (image_cropper)
- [ ] Upload vers Appwrite
- [ ] Réorganiser l'ordre (drag & drop)
- [ ] Supprimer une image
- [ ] Indication de l'image principale

#### Étape 5: Localisation
- [ ] Sélection ville (dropdown)
- [ ] Sélection quartier (dropdown)
- [ ] Adresse exacte (TextField)
- [ ] Map picker pour pin exact
- [ ] Bouton "Utiliser ma position actuelle"
- [ ] Affichage coordonnées

#### Étape 6: Récapitulatif
- [ ] Affichage de toutes les infos
- [ ] Possibilité de revenir en arrière
- [ ] Bouton "Publier"
- [ ] Loading state pendant la publication
- [ ] Redirection vers le dashboard

**Navigation entre étapes**:
- PageView avec indicateur
- Boutons Précédent/Suivant
- Validation à chaque étape

### 4. Dashboard Propriétaire ⏱️ ~5h
**Fichier**: `lib/presentation/pages/dashboard/dashboard_page.dart`

#### Section Statistiques
- [ ] Card: Total annonces
- [ ] Card: Annonces actives
- [ ] Card: Total vues
- [ ] Card: Total favoris
- [ ] Graphique des vues (optionnel)

#### Section Liste Annonces
- [ ] Liste scrollable des annonces
- [ ] Card par annonce avec:
  - Image miniature
  - Titre
  - Prix
  - Statut (active/inactive/rented)
  - Statistiques (vues, favoris)
  - Actions: Modifier, Supprimer, Changer statut
- [ ] Pull to refresh
- [ ] Bouton FAB "Ajouter une annonce"

#### Modals/Dialogs
- [ ] Confirmation de suppression
- [ ] Changement de statut
- [ ] Indicateur de chargement

## 🟡 Priorité Moyenne (Améliorations UX)

### 5. Page Édition Profil ⏱️ ~2h
**Fichier**: `lib/presentation/pages/profile/edit_profile_page.dart`

- [ ] Form avec validation
- [ ] Champs: Nom, Téléphone
- [ ] Upload photo de profil
- [ ] Crop image
- [ ] Upload vers Appwrite
- [ ] Bouton Enregistrer
- [ ] Retour avec confirmation

### 6. Page Reset Password ⏱️ ~1h
**Fichier**: `lib/presentation/pages/auth/forgot_password_page.dart`

- [ ] TextField email
- [ ] Validation
- [ ] Bouton envoyer
- [ ] Loading state
- [ ] Message de succès
- [ ] Redirection vers login

### 7. Notifications & Messages ⏱️ ~3h
**Fichier**: `lib/presentation/pages/messages/messages_page.dart`

- [ ] Liste des conversations
- [ ] Page de chat simple
- [ ] Envoi de message
- [ ] Réception en temps réel (Firestore)
- [ ] Notifications push (optionnel)

### 8. Historique de Recherche ⏱️ ~1h

- [ ] Sauvegarder les recherches récentes
- [ ] Afficher dans la page search
- [ ] Possibilité de supprimer
- [ ] Limite à 10 recherches

## 🟢 Priorité Basse (Nice to Have)

### 9. Animations & Transitions ⏱️ ~2h

- [ ] Hero animations sur les images
- [ ] Transitions de page personnalisées
- [ ] Animations de chargement (shimmer)
- [ ] Micro-interactions (ripple, scale)

### 10. Internationalisation (i18n) ⏱️ ~3h

- [ ] Package flutter_localizations
- [ ] Fichiers de traduction FR/EN
- [ ] Sélection de langue
- [ ] Format dates selon locale

### 11. Mode Hors Ligne ⏱️ ~4h

- [ ] Cache des annonces (Hive/SQLite)
- [ ] Indicateur connexion
- [ ] Queue de synchronisation
- [ ] Gestion conflits

### 12. Partage Social ⏱️ ~2h

- [ ] Meta tags pour partage
- [ ] Deep links
- [ ] Boutons partage réseaux sociaux
- [ ] Screenshot pour partage

### 13. Amélioration Carte ⏱️ ~2h

- [ ] Clustering des markers
- [ ] Affichage prix sur markers
- [ ] Vue carte dans home page
- [ ] Filtre par rayon

### 14. Tests ⏱️ ~8h

#### Tests Unitaires
- [ ] Validators
- [ ] Format utils
- [ ] Models
- [ ] Repositories (mockés)

#### Tests Widgets
- [ ] Login page
- [ ] Register page
- [ ] Listing card
- [ ] Custom buttons

#### Tests Intégration
- [ ] Flow authentification
- [ ] Flow création annonce
- [ ] Flow favoris

## 🔧 Optimisations & Refactoring

### Performance ⏱️ ~3h
- [ ] Lazy loading des images
- [ ] Pagination des listings
- [ ] Optimisation des requêtes Firestore
- [ ] Compression des images avant upload
- [ ] Cache des données API

### Code Quality ⏱️ ~2h
- [ ] Lint rules strictes
- [ ] Documentation des méthodes publiques
- [ ] Extraction de constantes magiques
- [ ] Refactor des widgets trop lourds

### Accessibilité ⏱️ ~2h
- [ ] Semantics pour screen readers
- [ ] Contraste des couleurs (WCAG AA)
- [ ] Tailles de texte ajustables
- [ ] Navigation au clavier (web)

## 📊 Récapitulatif Temps Estimé

| Priorité | Fonctionnalités | Temps Total |
|----------|----------------|-------------|
| 🔴 Haute | 4 items | ~20h |
| 🟡 Moyenne | 4 items | ~9h |
| 🟢 Basse | 6 items | ~21h |
| 🔧 Optimisations | 3 items | ~7h |
| **TOTAL** | **17 items** | **~57h** |

## 🎯 Roadmap Suggéré

### Sprint 1 (1 semaine) - MVP Complet
- [x] Configuration & Architecture
- [x] Auth pages
- [x] Home page
- [x] Favoris page
- [x] Profil page
- [ ] Détail annonce
- [ ] Recherche basique

### Sprint 2 (1 semaine) - Propriétaires
- [ ] Dashboard propriétaire
- [ ] Formulaire ajout annonce (6 étapes)
- [ ] Édition annonce

### Sprint 3 (1 semaine) - Polish
- [ ] Recherche avancée avec filtres
- [ ] Édition profil
- [ ] Messages/Chat basique
- [ ] Animations

### Sprint 4 (1 semaine) - Production Ready
- [ ] Tests
- [ ] Optimisations
- [ ] Documentation
- [ ] Déploiement stores

## 📝 Notes

- Chaque item peut être développé indépendamment
- Les estimations incluent tests et documentation
- Prioriser selon les besoins métier
- Possibilité de paralléliser certaines tâches

---

**Dernière mise à jour**: Décembre 2024
**Contributeurs**: Équipe TogoStay
