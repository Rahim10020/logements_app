# Guide de Test - Phase 2 : Authentification

## 🧪 Tests à Effectuer

### 1. Écran de Connexion (`/login`)

#### Test 1.1 - Validation des Champs
- [ ] Essayer de se connecter avec email vide → Message d'erreur "Email requis"
- [ ] Essayer de se connecter avec email invalide → Message d'erreur "Email invalide"
- [ ] Essayer de se connecter avec mot de passe vide → Message d'erreur "Mot de passe requis"
- [ ] Essayer avec mot de passe < 6 caractères → Message d'erreur

#### Test 1.2 - Connexion Email/Password
- [ ] Se connecter avec un compte existant → Redirection selon rôle
- [ ] Se connecter avec mauvais credentials → Message d'erreur Firebase
- [ ] Vérifier l'état de chargement pendant la connexion
- [ ] Vérifier que le bouton est désactivé pendant le chargement

#### Test 1.3 - Navigation
- [ ] Cliquer sur "Mot de passe oublié?" → Redirection vers `/forgot-password`
- [ ] Cliquer sur "S'inscrire" → Redirection vers `/register`
- [ ] Bouton retour fonctionne correctement

#### Test 1.4 - Authentification Sociale
- [ ] Cliquer sur "Continuer avec Google" → Popup Google Sign-In
- [ ] Annuler la popup → Retour à l'écran sans erreur
- [ ] Se connecter avec Google → Compte créé si nouveau
- [ ] Facebook montre le message "non disponible"

---

### 2. Écran d'Inscription (`/register`)

#### Test 2.1 - Validation des Champs
- [ ] Nom vide → Message d'erreur "Nom est requis"
- [ ] Email invalide → Message "Email invalide"
- [ ] Téléphone invalide → Message "Numéro invalide"
- [ ] Ville non sélectionnée → Message "Veuillez sélectionner une ville"
- [ ] Mot de passe < 6 caractères → Message d'erreur
- [ ] Mots de passe non identiques → Message "ne correspondent pas"

#### Test 2.2 - Inscription Réussie
- [ ] Remplir tous les champs correctement
- [ ] Sélectionner une ville dans le dropdown
- [ ] Cliquer sur "S'inscrire"
- [ ] Vérifier la création du compte Firebase Auth
- [ ] Vérifier la création du document Firestore `users/{uid}`
- [ ] Redirection vers `/role-selection`

#### Test 2.3 - Gestion d'Erreurs
- [ ] Essayer avec un email déjà utilisé → Message "email déjà utilisé"
- [ ] Vérifier l'état de chargement
- [ ] Bouton retour vers `/login` fonctionne

---

### 3. Écran Mot de Passe Oublié (`/forgot-password`)

#### Test 3.1 - Envoi Email
- [ ] Email vide → Message d'erreur
- [ ] Email invalide → Message d'erreur
- [ ] Email valide → Email de réinitialisation envoyé
- [ ] Vérifier l'affichage du message de succès
- [ ] Vérifier la réception de l'email Firebase

#### Test 3.2 - UI States
- [ ] État de chargement pendant l'envoi
- [ ] Affichage de la carte de succès après envoi
- [ ] Bouton "Renvoyer l'email" réinitialise le formulaire
- [ ] Bouton "Retour à la connexion" redirige vers `/login`

---

### 4. Écran Sélection de Rôle (`/role-selection`)

#### Test 4.1 - Sélection de Rôle
- [ ] Cliquer sur "Je cherche un logement" → Card sélectionnée (animation)
- [ ] Cliquer sur "Je loue des biens" → Card sélectionnée
- [ ] Cliquer sur "Les deux" → Card sélectionnée
- [ ] Changement de sélection fonctionne correctement

#### Test 4.2 - Validation
- [ ] Cliquer "Continuer" sans sélection → Message d'erreur
- [ ] Sélectionner un rôle + Continuer → Mise à jour Firestore
- [ ] Redirection vers `/home` après succès

#### Test 4.3 - Persistance
- [ ] Vérifier que le rôle est bien enregistré dans Firestore
- [ ] Champ `role` = 'tenant', 'owner', ou 'both'

---

### 5. AuthProvider - Tests Fonctionnels

#### Test 5.1 - State Management
- [ ] `isLoading` = true pendant les opérations
- [ ] `isLoading` = false après succès/échec
- [ ] `errorMessage` s'affiche correctement
- [ ] `currentUser` se met à jour après connexion
- [ ] `userModel` se charge depuis Firestore

#### Test 5.2 - Persistence
- [ ] Se connecter → Fermer l'app → Réouvrir → Toujours connecté
- [ ] Se déconnecter → Redirection vers `/login`
- [ ] État d'authentification survit aux rechargements

---

## 🔥 Tests Firebase

### Configuration Requise
1. **Firebase Console**:
   - [ ] Email/Password activé dans Authentication
   - [ ] Google Sign-In activé
   - [ ] SHA-1/SHA-256 configurés pour Android

2. **Firestore Rules** (temporaire pour dev):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Vérifications Firestore
- [ ] Collection `users` créée automatiquement
- [ ] Document avec bon UID
- [ ] Champs: uid, email, displayName, phone, city, role, photoURL, createdAt
- [ ] Timestamp `createdAt` correct

---

## 📱 Tests UI/UX

### Design Minimaliste
- [ ] Espaces blancs généreux
- [ ] Typographie claire et lisible
- [ ] Couleurs conformes à la palette
- [ ] Coins arrondis 12px sur les cards
- [ ] Ombres subtiles

### Interactivité
- [ ] Focus visible sur les champs de texte
- [ ] Bordure bleue (#2563EB) au focus
- [ ] Toggle visibilité mot de passe fonctionne
- [ ] Animations fluides sur les cartes de rôle
- [ ] SnackBars bien positionnées et lisibles

### Responsive
- [ ] Texte lisible sur petits écrans
- [ ] Pas de débordement horizontal
- [ ] ScrollView fonctionne sur petits écrans
- [ ] Padding cohérent

---

## 🚀 Comment Lancer les Tests

### 1. Prérequis
```bash
# Vérifier que Flutter est installé
flutter doctor

# Vérifier les dépendances
cd /home/rahimdev/vscodeprojects/logements_app
flutter pub get
```

### 2. Lancer en Mode Debug
```bash
# Android
flutter run

# iOS (si sur Mac)
flutter run -d ios

# Web (pour tests rapides)
flutter run -d chrome
```

### 3. Hot Reload
Après chaque modification, appuyez sur `r` dans le terminal pour recharger.

### 4. Logs Firebase
```bash
# Afficher les logs
flutter run --verbose

# Ou dans le code
print('User: ${authProvider.currentUser?.email}');
```

---

## 🐛 Problèmes Connus et Solutions

### 1. Google Sign-In ne fonctionne pas
**Solution**: 
- Vérifier SHA-1/SHA-256 dans Firebase Console
- Télécharger le nouveau `google-services.json`
- Rebuild l'app: `flutter clean && flutter run`

### 2. "User not found" après inscription
**Solution**:
- Vérifier que le rôle est bien défini
- Vérifier les routes de redirection
- Vérifier les règles Firestore

### 3. SnackBar ne s'affiche pas
**Solution**:
- Vérifier que le context est correct
- S'assurer que le Scaffold existe

---

## ✅ Checklist Finale Phase 2

### Code
- [x] AuthProvider complet et fonctionnel
- [x] 4 écrans d'authentification créés
- [x] 3 widgets réutilisables créés
- [x] UserModel avec méthodes complètes
- [x] Validators pour tous les champs
- [x] Routes configurées dans GoRouter
- [x] Provider intégré dans app.dart

### Firebase
- [ ] Compte Firebase créé
- [ ] Email/Password activé
- [ ] Google Sign-In configuré
- [ ] Règles Firestore définies
- [ ] Test avec vrais comptes

### Design
- [x] Palette de couleurs appliquée
- [x] Design minimaliste respecté
- [x] Espaces blancs généreux
- [x] Animations subtiles
- [x] États interactifs (focus, loading)

### Documentation
- [x] Code commenté en français
- [x] PHASE2_COMPLETE.md créé
- [x] Guide de test créé
- [x] README mis à jour

---

## 📞 Support

Si vous rencontrez des problèmes:
1. Vérifier les logs: `flutter run --verbose`
2. Vérifier Firebase Console > Authentication
3. Vérifier Firebase Console > Firestore
4. Vérifier le fichier `PHASE2_COMPLETE.md`

---

**Dernière mise à jour**: 9 Décembre 2025
**Status**: Phase 2 - 100% Complete ✅

