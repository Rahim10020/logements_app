#!/bin/bash

# Script de configuration automatique pour TogoStay
# Ce script aide à configurer rapidement l'environnement de développement

echo "🏠 Configuration de TogoStay - Application Mobile"
echo "================================================"
echo ""

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé!"
    echo "📥 Installez Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter détecté: $(flutter --version | head -n 1)"
echo ""

# Vérifier la version de Flutter
FLUTTER_VERSION=$(flutter --version | grep -oP 'Flutter \K[0-9]+\.[0-9]+')
REQUIRED_VERSION="3.5"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$FLUTTER_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "⚠️  Version Flutter < 3.5 détectée. Une mise à jour est recommandée."
    read -p "Continuer quand même? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Nettoyage
echo "🧹 Nettoyage du projet..."
flutter clean

# Installation des dépendances
echo "📦 Installation des dépendances..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'installation des dépendances"
    exit 1
fi

echo "✅ Dépendances installées avec succès"
echo ""

# Vérifier les plateformes disponibles
echo "📱 Plateformes disponibles:"
flutter devices

echo ""
echo "🎉 Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Configurez Firebase (voir QUICKSTART.md)"
echo "2. Configurez Appwrite (voir QUICKSTART.md)"
echo "3. Lancez l'app: flutter run"
echo ""
echo "📚 Documentation:"
echo "- Guide complet: README_TOGOSTAY.md"
echo "- Démarrage rapide: QUICKSTART.md"
echo ""
