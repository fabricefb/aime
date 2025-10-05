#!/bin/bash
# Script de post-déploiement pour AIME RDC
# À exécuter manuellement après chaque déploiement via cPanel

set -e  # Arrêter en cas d'erreur

echo "🚀 Début du post-déploiement AIME..."

# Variables
CPANEL_USER="cp2639565p41"
PROJECT_DIR="/home/$CPANEL_USER/public_html"
VENV_DIR="/home/$CPANEL_USER/virtualenv/public_html/3.9"

# Activer l'environnement virtuel
source "$VENV_DIR/bin/activate"

# Aller dans le répertoire du projet
cd "$PROJECT_DIR"

echo "📦 Installation des dépendances Python..."
pip install -r requirements.txt --quiet

echo "🗄️  Application des migrations de base de données..."
python manage.py migrate --noinput

echo "📁 Collecte des fichiers statiques..."
python manage.py collectstatic --noinput --clear

echo "🔐 Correction des permissions..."
chmod -R 755 "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR/staticfiles" 2>/dev/null || true
chmod -R 755 "$PROJECT_DIR/media" 2>/dev/null || true

echo "🔄 Redémarrage de l'application..."
mkdir -p "$PROJECT_DIR/tmp"
touch "$PROJECT_DIR/tmp/restart.txt"

echo "✅ Post-déploiement terminé avec succès!"
echo "🌐 Votre site devrait être accessible à https://aime-rdc.org"
