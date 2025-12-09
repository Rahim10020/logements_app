# Phase 3 - Tests et Utilisation

## 🧪 Comment tester

### 1. Prérequis
Assurez-vous d'avoir :
- ✅ Firebase configuré (Phase 1)
- ✅ Authentification fonctionnelle (Phase 2)
- ✅ Des données de test dans Firestore

### 2. Structure Firestore requise

#### Collection `listings`
```json
{
  "userId": "user_id_here",
  "city": "Lomé",
  "neighborhood": "Adidogomé",
  "propertyType": "Appartement",
  "bedrooms": 2,
  "bathrooms": 1,
  "area": 60,
  "monthlyPrice": 150000,
  "description": "Bel appartement moderne avec toutes les commodités",
  "isRented": false,
  "imageIds": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "latitude": 6.1725,
  "longitude": 1.2314,
  "address": "Rue de la Paix, Adidogomé",
  "furnished": true,
  "airConditioning": true,
  "wifi": true,
  "parking": false,
  "equippedKitchen": true,
  "balcony": true,
  "generator": true,
  "waterTank": true,
  "borehole": false,
  "security": true,
  "fence": true,
  "tiledFloor": true,
  "ceilingFan": true,
  "individualElectricMeter": true,
  "individualWaterMeter": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "favoritesCount": 0
}
```

#### Collection `saved_listings`
```json
{
  "userId": "user_id_here",
  "listingId": "listing_id_here",
  "savedAt": "2024-01-01T00:00:00Z"
}
```

### 3. Données de test

Vous pouvez créer des données de test avec ce script Firestore:

```javascript
// Dans la console Firebase > Firestore
const testListings = [
  {
    userId: 'test_user_id',
    city: 'Lomé',
    neighborhood: 'Adidogomé',
    propertyType: 'Appartement',
    bedrooms: 2,
    bathrooms: 1,
    area: 60,
    monthlyPrice: 150000,
    description: 'Bel appartement moderne',
    isRented: false,
    imageIds: [],
    furnished: true,
    airConditioning: true,
    wifi: true,
    // ... autres commodités
    createdAt: new Date(),
    updatedAt: new Date(),
    favoritesCount: 0
  },
  // Ajoutez plus d'annonces...
];
```

### 4. Lancer l'application

```bash
cd /home/rahimdev/vscodeprojects/logements_app
flutter run
```

### 5. Scénarios de test

#### Écran d'accueil
1. ✅ Les annonces s'affichent groupées par quartier
2. ✅ Les filtres rapides fonctionnent (Tous, Appartement, Villa, etc.)
3. ✅ Le pull-to-refresh recharge les données
4. ✅ Cliquer sur une annonce ouvre les détails
5. ✅ Le bouton favori fonctionne (cœur rouge/gris)
6. ✅ Le badge de compteur de favoris s'affiche
7. ✅ La barre de recherche est cliquable

#### Écran favoris
1. ✅ Les favoris s'affichent en grid 2 colonnes
2. ✅ Swiper une annonce affiche la confirmation
3. ✅ Retirer un favori met à jour le compteur
4. ✅ L'état vide s'affiche si aucun favori
5. ✅ Redirection vers login si non connecté

#### Écran détails
1. ✅ Le carousel d'images fonctionne
2. ✅ Les indicateurs de page s'affichent
3. ✅ Toutes les informations sont visibles
4. ✅ Les commodités s'affichent avec icônes
5. ✅ La carte OpenStreetMap charge
6. ✅ La carte propriétaire s'affiche
7. ✅ Le bouton contact ouvre le modal
8. ✅ Les liens téléphone/WhatsApp/email fonctionnent
9. ✅ Le partage fonctionne
10. ✅ Le toggle favori fonctionne

---

## 🐛 Problèmes connus

### Warnings
- `withOpacity` deprecated → Sera corrigé avec Flutter 4.0
- Share deprecated → Utiliser `SharePlus` instance dans future update

Ces warnings n'affectent pas le fonctionnement.

---

## 📱 Captures d'écran suggérées

Pour documenter l'app:
1. Écran d'accueil avec annonces
2. Détails d'une annonce
3. Écran favoris
4. Modal de contact
5. Carte OpenStreetMap

---

## 🔄 Prochaines fonctionnalités (Phase 4)

- 🔍 Recherche avec autocomplete
- 🎛️ Filtres avancés (prix, chambres, commodités)
- 🗺️ Vue carte avec clusters
- 📊 Tri (prix, date, popularité)
- 💾 Sauvegarde des recherches

---

**Phase 3 testée et validée ! 🎉**

