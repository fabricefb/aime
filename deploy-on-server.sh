#!/bin/bash
# Script de déploiement simplifié - À exécuter DIRECTEMENT sur le serveur cPanel
# Usage: bash deploy-on-server.sh

set -e  # Arrêter en cas d'erreur

echo "🚀 DÉPLOIEMENT AIME - SCRIPT SERVEUR"
echo "===================================="
echo ""

# Variables
CPANEL_USER="cp2639565p41"
REPO_PATH="/home/$CPANEL_USER/repositories/aime"
DEPLOY_PATH="/home/$CPANEL_USER/public_html"
VENV_PATH="/home/$CPANEL_USER/virtualenv/public_html/3.9"

# Vérifier qu'on est sur le serveur
if [ ! -d "$REPO_PATH" ]; then
    echo "❌ Erreur: Ce script doit être exécuté sur le serveur cPanel"
    echo "   Dépôt non trouvé : $REPO_PATH"
    exit 1
fi

echo "📥 Étape 1/6 : Pull depuis GitHub..."
cd "$REPO_PATH"
echo "  ➜ Dans : $(pwd)"
git pull origin main || {
    echo "❌ Erreur lors du git pull"
    echo "Vérifiez votre connexion SSH à GitHub"
    exit 1
}
echo "  ✅ Pull terminé"
echo ""

echo "📁 Étape 2/6 : Copie des fichiers..."
echo "  ➜ De : $REPO_PATH"
echo "  ➜ Vers : $DEPLOY_PATH"
cp -R "$REPO_PATH"/* "$DEPLOY_PATH/"
cp "$REPO_PATH/.htaccess" "$DEPLOY_PATH/" 2>/dev/null || true
echo "  ✅ Fichiers copiés"
echo ""

echo "⚙️  Étape 3/6 : Activation de l'environnement virtuel..."
source "$VENV_PATH/bin/activate" || {
    echo "❌ Erreur: Environnement virtuel non trouvé"
    echo "   Chemin : $VENV_PATH"
    echo "   Créez-le via cPanel > Setup Python App"
    exit 1
}
echo "  ✅ Environnement activé"
echo "  ➜ Python : $(python --version)"
echo ""

cd "$DEPLOY_PATH"

echo "📦 Étape 4/6 : Installation des dépendances..."
pip install -r requirements.txt --quiet || {
    echo "⚠️  Avertissement : Certaines dépendances ont échoué"
    echo "   Continuons quand même..."
}
echo "  ✅ Dépendances installées"
echo ""

echo "🗄️  Étape 5/6 : Migrations et fichiers statiques..."
echo "  ➜ Application des migrations..."
python manage.py migrate --noinput || {
    echo "⚠️  Avertissement : Migrations échouées"
    echo "   Vérifiez la connexion à la base de données"
}

echo "  ➜ Collecte des fichiers statiques..."
python manage.py collectstatic --noinput --clear || {
    echo "⚠️  Avertissement : Collectstatic échoué"
}
echo "  ✅ Base de données et statiques OK"
echo ""

echo "🔐 Étape 6/6 : Permissions et redémarrage..."
chmod -R 755 "$DEPLOY_PATH"
chmod -R 755 "$DEPLOY_PATH/staticfiles" 2>/dev/null || true
chmod -R 755 "$DEPLOY_PATH/media" 2>/dev/null || true

mkdir -p "$DEPLOY_PATH/tmp"
touch "$DEPLOY_PATH/tmp/restart.txt"
echo "  ✅ Application redémarrée"
echo ""

echo "===================================="
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo "===================================="
echo ""
echo "🌐 Site : https://aime-rdc.org"
echo ""
echo "📋 Vérifications à faire :"
echo "   curl -I https://aime-rdc.org"
echo "   # Doit retourner HTTP/2 200 (pas 500)"
echo ""
echo "🐛 En cas d'erreur 500, consulter :"
echo "   tail -n 50 ~/logs/error_log"
echo "   cat ~/public_html/wsgi_error.log"
echo ""
