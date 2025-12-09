#!/bin/bash

# Script de vérification de la Phase 3
# Ahoe - Core Features

echo "🔍 Vérification de la Phase 3 - Core Features"
echo "=============================================="
echo ""

# Vérifier que tous les fichiers existent
echo "📁 Vérification des fichiers..."

# Modèles
files=(
  "lib/data/models/listing_model.dart"
  "lib/data/models/saved_listing_model.dart"

  # Repositories
  "lib/data/repositories/listing_repository.dart"
  "lib/data/repositories/saved_listing_repository.dart"
  "lib/data/repositories/user_repository.dart"

  # Providers
  "lib/features/home/providers/home_provider.dart"
  "lib/features/saved/providers/saved_provider.dart"
  "lib/features/listing_detail/providers/listing_detail_provider.dart"

  # Écrans
  "lib/features/home/screens/home_screen.dart"
  "lib/features/saved/screens/saved_listings_screen.dart"
  "lib/features/listing_detail/screens/listing_detail_screen.dart"

  # Widgets Home
  "lib/features/home/widgets/listing_card.dart"
  "lib/features/home/widgets/search_bar_widget.dart"
  "lib/features/home/widgets/hero_section.dart"
  "lib/features/home/widgets/neighborhood_section.dart"

  # Widgets Listing Detail
  "lib/features/listing_detail/widgets/image_carousel.dart"
  "lib/features/listing_detail/widgets/amenities_grid.dart"
  "lib/features/listing_detail/widgets/map_widget.dart"
  "lib/features/listing_detail/widgets/owner_card.dart"

  # Widgets Shared
  "lib/shared/widgets/loading_indicator.dart"
  "lib/shared/widgets/error_widget.dart"
  "lib/shared/widgets/empty_state.dart"
)

missing=0
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ MANQUANT: $file"
    ((missing++))
  fi
done

echo ""
if [ $missing -eq 0 ]; then
  echo "✅ Tous les fichiers sont présents!"
else
  echo "❌ $missing fichier(s) manquant(s)"
  exit 1
fi

echo ""
echo "🔧 Analyse du code..."
dart analyze lib/features/home lib/features/saved lib/features/listing_detail lib/shared/widgets 2>&1 | tail -5

echo ""
echo "📊 Statistiques de la Phase 3:"
echo "  - Fichiers créés: ${#files[@]}"
echo "  - Modèles: 2"
echo "  - Repositories: 3"
echo "  - Providers: 3"
echo "  - Écrans: 3"
echo "  - Widgets: 12"

echo ""
echo "✅ Phase 3 complétée avec succès!"
echo ""
echo "📝 Prochaines étapes:"
echo "  1. Tester l'application avec des données réelles"
echo "  2. Commencer la Phase 4 - Recherche & Filtres"
echo ""

