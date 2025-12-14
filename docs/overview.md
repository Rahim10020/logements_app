# Aperçu haute‑niveau du flux utilisateur — logements_app

Date : 2025-12-14

Résumé
------
Document unique (français) présentant :
- Un aperçu haute‑niveau des parcours utilisateurs de l'application.
- Un diagramme de flux (Mermaid) représentant les routes et conditions d'accès.
- Les fichiers et symboles clés à consulter dans le code.
- Des suggestions d'amélioration priorisées et actionnables.

Objectif
--------
Fournir une carte claire des parcours utilisateurs (découverte, authentification, accès protégé, chat, dashboard propriétaire) pour faciliter compréhension, maintenance et planification d'évolutions.

Table des matières
------------------
1. Points d'entrée & routes principales
2. Parcours utilisateurs (haute‑niveau)
   - Authentification (Login / Register / Role selection)
   - Découverte & Home
   - Recherche
   - Détail d'annonce
   - Favoris
   - Profil / Dashboard / Ajout d'annonce
   - Messagerie (Chat)
3. Diagramme de flux (Mermaid)
4. Fichiers & symboles clés
5. Suggestions d'amélioration (priorisées)
6. Comment générer une image PNG du diagramme

1) Points d'entrée & routes principales
--------------------------------------
- Point d'entrée : `lib/main.dart` — initialise Firebase, définit orientation et lance l'app `App`.
- Widget racine : `lib/app.dart` — instancie les `providers` (ChangeNotifier) et configure `MaterialApp.router`.
- Router central : `lib/core/config/app_router.dart` — `AppRouter.router` définit toutes les routes et redirections.
  - `initialLocation: '/home'`
  - Routes d'auth : `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/role-selection` (alias `/login`, `/register`, ...)
  - Routes principales : `/home`, `/search`, `/saved`, `/listing/:id`, `/profile` (+ `/profile/settings`, `/profile/edit`)
  - Dashboard / annonce : `/dashboard`, `/dashboard/add-listing`, `/dashboard/edit-listing/:id`
  - Chat : `/conversations`, `/chat/:id`

2) Parcours utilisateurs — aperçu haute‑niveau
---------------------------------------------
Chaque parcours mentionne : point d'entrée UI, conditions (auth/role), actions et providers impliqués.

A. Authentification (Login / Register / Role selection)
- Ecrans : `lib/features/auth/screens/login_screen.dart`, `register_screen.dart`, `role_selection_screen.dart`, `forgot_password_screen.dart`.
- Provider principal : `lib/features/auth/providers/auth_provider.dart` (`AuthProvider`).
- Logique :
  - L'utilisateur non connecté peut accéder à `/auth/login` ou `/auth/register`.
  - Après `signIn` ou `signUp`, le code vérifie `authProvider.userModel?.role` :
    - Si `role` est null ou vide → redirection vers `/role-selection`.
    - Sinon → redirection vers `/home`.
  - AuthProvider écoute les changements via `_auth.authStateChanges()` et charge les données Firestore (`users` collection définie dans `FirebaseConfig`).
  - Actions supports : Google Sign-In (implémenté partiellement), Facebook (placeholder), reset password.

B. Découverte & Home
- Ecran : `lib/features/home/screens/home_screen.dart`.
- Provider : `HomeProvider` (registré dans `lib/app.dart`).
- Flux : app démarre → `initialLocation` `/home` → `HomeScreen` affiche hero, barre recherche, filtres rapides et sections par quartier.
- Actions :
  - Taper sur une `ListingCard` → `context.push('/listing/${listing.id}')` (route `listing-detail`).
  - Appuyer sur la barre recherche → `context.push('/search')`.
  - Ajouter aux favoris déclenche `SavedProvider.toggleSaved` ; si non connecté → redirige vers `/auth/login`.

C. Recherche
- Ecran : `lib/features/search/screens/search_screen.dart`.
- Provider : `SearchProvider`.
- Flux : recherche initiale (post frame) → filtres rapides (villes, tri) → bouton flottant ouvre bottom sheet des filtres avancés → résultat en grid.
- Actions : cliquer sur un item → `context.push('/listing/${id}')` ; toggler favoris → passe par `SavedProvider`, vérifie `AuthProvider.currentUser`.

D. Détail d'annonce
- Ecran : `lib/features/listing_detail/screens/listing_detail_screen.dart`.
- Provider : `ListingDetailProvider` (chargement de `listing` par id) ; utilise `UserRepository` pour charger propriétaire.
- Flux : `/listing/:id` → `ListingDetailScreen(listingId)` → affiche carousel, prix, caractéristiques, commodités, carte, owner card.
- Actions :
  - Favori : `SavedProvider.toggleSaved` (si non connecté → `/auth/login`).
  - Partage : `share_plus` utilisé.
  - Contacter : ouvre options / crée ou navigue vers conversation → `/chat/:conversationId` (via `ChatProvider`).

E. Favoris
- Ecran : `lib/features/saved/screens/saved_listings_screen.dart`.
- Provider : `SavedProvider`.
- Règle : accès protégé — si `AuthProvider.currentUser == null` → redirige vers `/auth/login`.
- Flux : charge listes favorites (`fetchSavedListings(uid)`) — affiche grid ; swipe pour retirer, ou bouton retire.

F. Profil / Dashboard / Ajout d'annonce
- Profil : `lib/features/profile/screens/profile_screen.dart` — protegé; si non connecté → `/auth/login`.
  - Provider : `ProfileProvider`.
  - Menu : Edit profile (`/profile/edit`), Mon Dashboard (si `user.role == 'owner'`), Mes Favoris, paramètres.
- Dashboard : `lib/features/dashboard/screens/dashboard_screen.dart` — accès protégé, recommandé pour `role == 'owner'`.
  - Provider : `DashboardProvider`.
  - Actions : voir statistiques, lister annonces, éditer (`/dashboard/edit-listing/:id`), ajouter (`/dashboard/add-listing`).
- Add/Edit Listing : `lib/features/dashboard/screens/add_edit_listing_screen.dart`.
  - Provider : `AddEditListingProvider`.
  - Gère sélection/upload images, localisation, caractéristiques, prix, description, commodités, envoi vers repository/Firestore.

G. Messagerie (Chat)
- Ecrans : `lib/features/chat/screens/conversations_screen.dart`, `lib/features/chat/screens/chat_screen.dart`.
- Provider : `ChatProvider`.
- Flux : ouvrir `/conversations` (protégé) → liste conversations (charges via `fetchConversations(uid)`) → tap → `/chat/:id` ++ `extra` contient `otherUserData` et `listingData`.
- Chat : messages streamées via `ChatProvider.watchMessages(conversationId)` ; envoi via `ChatProvider.sendMessage(...)` ; marqueurs lecture via `markMessagesAsRead`.

3) Diagramme de flux (Mermaid)
-------------------------------
Copiez le bloc Mermaid ci‑dessous dans un renderer (VSCode mermaid preview, mermaid.live, ou `mmdc`) pour visualiser le diagramme ; il est volontairement haute‑niveau.

```mermaid
flowchart LR
  Start([Entrée App]) --> Home[/home\nHomeScreen\n(HomeProvider)/]
  Home --> Search[/search\nSearchScreen/]
  Home --> Listing[/listing/:id\nListingDetail/]
  Home --- Saved[/saved\nSavedListings/]
  Home --- Profile[/profile\nProfile/]
  Home --- Conversations[/conversations\nConversations/]

  %% Auth flows
  Login[/auth/login\nLoginScreen/] --> PostLogin{user.role set?}
  Register[/auth/register\nRegisterScreen/] --> PostLogin
  PostLogin -- yes --> Home
  PostLogin -- no --> RoleSel[/auth/role-selection\nRoleSelection/]
  RoleSel --> Home

  %% Access control
  Saved -. si non connecté -> Login .-> Saved
  Profile -. si non connecté -> Login .-> Profile
  Conversations -. si non connecté -> Login .-> Conversations
  Dashboard[/dashboard\nDashboardScreen/] -. si non connecté -> Login .-> Dashboard

  %% Listing interactions
  Listing -- "Favori (SavedProvider)" --> Saved
  Listing -- "Contacter (ChatProvider)" --> Conversations
  Listing -- "Voir Profil Proprio" --> Profile

  %% Dashboard create/edit
  Dashboard --> AddListing[/dashboard/add-listing\nAdd/Edit Listing/]
  Dashboard --> EditListing[/dashboard/edit-listing/:id/]

  style Login fill:#f9f,stroke:#333
  style RoleSel fill:#ff9,stroke:#333
  style Home fill:#9f9,stroke:#333
  style Listing fill:#9cf,stroke:#333
  style Dashboard fill:#f99,stroke:#333
```

Notes sur le diagramme
- Les flèches `-. si non connecté -> Login` indiquent la logique observée dans les écrans : plusieurs écrans vérifient `AuthProvider.currentUser` et redirigent vers `/auth/login` si nécessaire.
- La vérification du rôle est effectuée après connexion (dans `login_screen.dart` et `register_screen.dart`) et utilise `authProvider.userModel?.role`.

4) Fichiers & symboles clés
---------------------------
- Entrée : `lib/main.dart` (initialisation Firebase, `ProviderScope`)
- App : `lib/app.dart` (`MaterialApp.router`, providers enregistrés)
- Router : `lib/core/config/app_router.dart` — toutes les routes globales

Providers & fonctions importantes
- `lib/features/auth/providers/auth_provider.dart` — `AuthProvider`
  - `signIn(email, password)`, `signUp(...)`, `signInWithGoogle()`, `resetPassword(email)`, `updateUserRole(role)`, `signOut()`
  - Écoute : `_auth.authStateChanges().listen(_onAuthStateChanged)`
- `HomeProvider` — `fetchListings()`, `refreshListings()`, `applyFilter(...)` (voir `lib/features/home/providers/home_provider.dart`)
- `SearchProvider` — `search()`, `setSearchQuery(...)`, `clearAndSearch()`, filtres et `activeFiltersCount` (voir `lib/features/search/providers/search_provider.dart`)
- `ListingDetailProvider` — `fetchListingById(listingId)` (voir `lib/features/listing_detail/providers/listing_detail_provider.dart`)
- `SavedProvider` — `loadSavedIds(uid)`, `toggleSaved(uid, listingId)`, `removeFromSaved(uid, listingId)` (voir `lib/features/saved/providers/saved_provider.dart`)
- `ProfileProvider` — `loadProfile(userId)`, `updateProfile(...)` (voir `lib/features/profile/providers/profile_provider.dart`)
- `DashboardProvider` / `AddEditListingProvider` — création, édition, suppression d'annonces, upload d'images (voir `lib/features/dashboard/providers/*.dart`)
- `ChatProvider` — `fetchConversations(uid)`, `watchMessages(conversationId)`, `sendMessage(...)`, `markMessagesAsRead(...)` (voir `lib/features/chat/providers/chat_provider.dart`)

5) Suggestions d'amélioration (priorisées & actionnables)
--------------------------------------------------------
Chaque item inclut : priorité (P0 = haute, P1 = moyenne, P2 = basse), description et fichiers/symboles concernés.

P0 — Centraliser le gating d'accès/auth (middleware de route)
- Description : Actuellement plusieurs écrans vérifient `AuthProvider.currentUser` et appellent `context.go('/auth/login')`. Créer un middleware global ou une `GoRouter` redirect callback centralisée pour éviter répétitions et garantir cohérence.
- Avantage : Simplifie maintenance, évite oublis, comportement prévisible.
- Fichiers : `lib/core/config/app_router.dart`, `lib/features/auth/providers/auth_provider.dart`.

P0 — Système de rôles : forcer contrainte côté UI et backend
- Description : Vérifier et appliquer `user.role` systématiquement (propriétaire vs chercheur). Ajouter guards pour routes `/dashboard` et `/dashboard/*` et afficher onboarding de rôle si absent.
- Fichiers : `login_screen.dart`, `register_screen.dart`, `app_router.dart`, `profile_screen.dart`.

P1 — Tests unitaires / widget pour providers critiques
- Description : Ajouter tests pour `AuthProvider`, `SavedProvider`, `SearchProvider` et flows critiques (connexion → role → home). Mocker Firebase via fakes (ou firebase_emulator_suite) pour tests d'intégration.
- Fichiers : tests sous `test/`.

P1 — Gestion des erreurs et UX uniforme
- Description : Centraliser la logique d'affichage d'erreurs (snackbars) et ajouter erreurs détaillées pour les calls Firestore/FirebaseAuth. Uniformiser couleurs et niveaux (info/warn/error).
- Fichiers : composants `shared/widgets/error_widget.dart`, `shared/widgets/loading_indicator.dart`, et écrans qui affichent SnackBars (ex. `login_screen.dart`).

P1 — Améliorer upload d'images (retry / chunking / validation)
- Description : Ajouter validations côté client pour taille/format, gérer erreurs réseau et proposer retry ; pour gros uploads, envisager upload multipart ou service de traitement.
- Fichiers : `AddEditListingProvider`, `ProfileProvider`, `core/config/app_config.dart` (constantes image limits).

P2 — Analytics & instrumentation
- Description : Log des événements (connexion, inscription, création annonce, favori, message envoyé) afin d'optimiser produit.
- Fichiers : points d'interaction (screens providers) ; ajouter service `lib/core/analytics/*`.

P2 — Sécurité / Suppression compte et données
- Description : Implémenter suppression de compte côté backend et UI (confirmation, grasse suppression, export données) ; activer règles Firestore sécurisées.
- Fichiers : `profile_screen.dart`, `AuthProvider`, règles Firestore (non fournies dans ce repo).

6) Comment générer une image PNG du diagramme Mermaid
-----------------------------------------------------
Si vous souhaitez une image PNG (ex: `docs/flow.png`) depuis le diagramme Mermaid ci‑dessus :

- Option en local (recommandée) : installer `@mermaid-js/mermaid-cli` (npm) (`mmdc`) ou utiliser `mermaid-cli` dans un container.

Exemple commandes (bash) :

```bash
# installer si nécessaire
npm install -g @mermaid-js/mermaid-cli

# sauvegarder le bloc mermaid dans flow.mmd (ou extraire de ce fichier)
# puis générer png
mmdc -i flow.mmd -o docs/flow.png -w 1200
```

- Option en ligne : coller le bloc Mermaid dans https://mermaid.live/ puis exporter PNG.

Livrables créés
----------------
- `docs/overview.md`  (ce fichier)
- (Optionnel) `docs/flow.png` — peut être générée par vous ou par CI en suivant la commande ci‑dessus.

Notes finales
-------------
- Ce document donne un aperçu haute‑niveau : pour implémenter changements (ex. centralisation des guards), je peux proposer un patch code (édition de `app_router.dart` + tests). Indiquez si vous voulez que j'applique l'une des suggestions maintenant.
- Si vous voulez que je génère aussi `docs/flow.png` automatiquement dans le repo, je peux tenter d'exécuter la conversion ici si le runner dispose de `npm` / `mmdc`. Dites simplement "génère le PNG" et je le ferai.

---

Fin de `docs/overview.md`.

