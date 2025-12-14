# Aperçu du parcours utilisateur — Hauteur et logique (FR)

Ce document donne un aperçu haut-niveau et une logique pas-à-pas du parcours utilisateur implémenté dans l'application `logements_app`, ainsi que des suggestions d'amélioration prioritaires.

## 1. Résumé haute-niveau

- Entrée : l'utilisateur arrive dans l'application -> écran `Home`.
- Depuis `Home` l'utilisateur peut -> `Search`, consulter un `Listing` (Détail), accéder aux `Saved` (favoris), `Profile` (profil) et `Conversations` (messagerie).
- Les écrans sensibles (Saved, Profile, Conversations, Dashboard) demandent une authentification : s'il n'est pas connecté, redirection vers `/auth/login`.
- Après connexion, l'application vérifie si `user.role` est renseigné ; si non -> `RoleSelection`.
- Interactions principales sur un listing : sauvegarder (SavedProvider), contacter (ChatProvider), voir le profil du propriétaire.
- Pour les utilisateurs administrateurs/propriétaires : `Dashboard` permet de créer/éditer des listings (`Add/Edit Listing`).

## 2. Points d'entrée & navigation

- Start -> Home
- Home -> Search
- Home -> Listing (détail)  (route: `/listing/:id`)
- Home -> Saved (favoris)
- Home -> Profile
- Home -> Conversations

Navigation observée dans le code :
- `push` est utilisé pour empiler l'écran (conserver l'historique)
- `go` (ou équivalent) est utilisé quand la navigation doit remplacer l'historique (navigation non historique)

## 3. Flux d'authentification

- Routes : `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/role-selection`.
- Après `Login` / `Register` -> vérification `PostLogin{ user.role ? }` :
  - oui -> Home
  - non -> RoleSelection -> Home
- Accès restreint : tentatives d'accès à Saved/Profile/Conversations/Dashboard sans `AuthProvider.currentUser` redirigent vers Login.

## 4. Logique détaillée (étape par étape)

1. Ouverture app : le `HomeProvider` initialise l'état (lecture cache local / Firebase si présent).
2. L'utilisateur navigue : les routes publiques (Home, Search, Listing) sont accessibles sans auth.
3. Actions sur Listing :
   - Favoriser : met à jour `SavedProvider` (si non connecté -> rediriger vers Login)
   - Contacter : ouvre `Conversations` (création de chat si nécessaire)
   - Voir profil : ouvre `Profile` du propriétaire
4. Tentative d'accès à une écran protégé :
   - si `AuthProvider.currentUser == null` -> redirect `/auth/login`
   - après login, si `user.role` manquant -> `/auth/role-selection` pour compléter le profil
5. Dashboard (pour comptes éligibles) :
   - Accès à liste de ses annonces
   - Ajouter / Editer une annonce via `/dashboard/add-listing` ou `/dashboard/edit-listing/:id`

## 5. Hypothèses (inférées du code)
- `AuthProvider.currentUser` est la source de vérité pour l'authentification.
- `user.role` détermine si l'utilisateur a complété le onboarding (et possiblement les droits Dashboard).
- Les providers nommés (SavedProvider, ChatProvider, HomeProvider) contiennent la logique métier client et le caching local.
- Navigation distingue `push` vs `go` pour historique (ex: revenir vs remplacement d'écran).

## 6. Suggestions d'améliorations (priorisées)

Priorité élevée (corriger ou améliorer maintenant)
- Centraliser la logique d'accès protégé dans un middleware/router guard : éviter de répéter "if not auth -> redirect" dans chaque écran.
- Normaliser et documenter l'usage de `push` vs `go` (ou leurs équivalents) pour éviter des comportements inattendus dans l'historique.
- Vérifier et rendre idempotente la création de conversations (éviter doublons de thread quand on clique plusieurs fois rapidement).
- Ajouter des tests unitaires pour :
  - redirections non-auth
  - Post-login -> role selection
  - favorite/save toggle
- Protection anti-UX: afficher un loader + désactiver le bouton pendant les appels réseau pour éviter doubles-soumissions.

Priorité moyenne (améliorations d'UX et maintenance)
- Caching / pagination des listes (Search, Saved, Dashboard) pour réduire coûts Firebase/latence.
- Réessai/backoff pour opérations critiques (network failure)
- Gestion claire des erreurs utilisateurs (toasts/snackbars uniformes et traduits)
- Ajout d'un audit log côté client pour actions importantes (ajout annonce, suppression, contact)

Priorité basse (nice-to-have)
- Optimiser l'accessibilité (contraste, labels, ordre de tabulation)
- Analytics d'entonnoir (où drop-off dans le flow de contact/booking)
- Progressive enhancements : skeleton screens, lazy-loading images, préfetch de détail listing quand on survole.

## 7. Tests recommandés (minimaux)
- Tests unitaires pour providers principaux : AuthProvider, SavedProvider, ChatProvider.
- Tests d'intégration/navigation : 
  - non-auth -> tentative access protected route redirige vers login
  - login sans role -> atterrit sur role-selection
  - sauvegarder un listing met à jour la collection locale/remote

## 8. Qualité & validation effectuée maintenant
- Correction du fichier `docs/flow.mmd` : problème de parsing corrigé (virgule manquante dans déclaration `class` et note multi-lignes reformattée).
- Vérification des erreurs connues du fichier : seule une mise en garde liée au thème Mermaid dans l'éditeur (non bloquant) est retournée.

## 9. Fichiers modifiés / créés
- Modifié : `docs/flow.mmd` (corrections de syntaxe Mermaid)
- Créé : `docs/flow_overview.md` (ce fichier)

## 10. Prochaines étapes suggérées
1. Revoir le route guard global et factoriser les vérifications d'auth/role.
2. Ajouter un petit test d'intégration qui simule un utilisateur non-auth et vérifie la redirection.
3. Améliorer l'UX des boutons critiques (désactivation pendant loading).

---

Si vous voulez, je peux maintenant :
- ajouter un route-guard / middleware exemple dans le code (fichier + test),
- écrire les tests unitaires minimaux pour `AuthProvider` et `SavedProvider`, ou
- générer une image PNG du diagramme Mermaid (`flow.mmd`) en utilisant `mmdc` (il faudra installer mermaid-cli si non présent).

Dites-moi lequel de ces items vous voulez que j'exécute ensuite (ou je peux commencer par le route-guard si vous me laissez décider).
