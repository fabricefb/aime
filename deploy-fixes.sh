#!/bin/bash
# Script de déploiement des corrections sur cPanel
# À exécuter depuis votre machine locale

set -e  # Arrêter en cas d'erreur

echo "🚀 DÉPLOIEMENT DES CORRECTIONS SUR CPANEL AIME"
echo "=============================================="
echo ""

# Variables
CPANEL_HOST="aime-rdc.org"
CPANEL_USER="cp2639565p41"
REPO_PATH="/home/$CPANEL_USER/repositories/aime"
DEPLOY_PATH="/home/$CPANEL_USER/public_html"

echo "📡 Connexion au serveur cPanel..."
echo "Host: $CPANEL_HOST"
echo "User: $CPANEL_USER"
echo ""

# Étape 1 : Pull depuis GitHub dans le dépôt
echo "📥 Étape 1/5 : Pull des dernières modifications depuis GitHub..."
ssh $CPANEL_USER@$CPANEL_HOST << 'ENDSSH1'
cd /home/cp2639565p41/repositories/aime
echo "  ➜ Dans le dépôt : $(pwd)"
git status
echo ""
echo "  ➜ Pull depuis origin/main..."
git pull origin main
echo "  ✅ Pull terminé"
ENDSSH1

echo ""

# Étape 2 : Copier les fichiers vers public_html
echo "📁 Étape 2/5 : Copie des fichiers vers public_html..."
ssh $CPANEL_USER@$CPANEL_HOST << 'ENDSSH2'
echo "  ➜ Copie de /repositories/aime vers /public_html..."
cp -R /home/cp2639565p41/repositories/aime/* /home/cp2639565p41/public_html/
cp /home/cp2639565p41/repositories/aime/.htaccess /home/cp2639565p41/public_html/ 2>/dev/null || true
echo "  ✅ Fichiers copiés"
ENDSSH2

echo ""

# Étape 3 : Exécuter le post-déploiement
echo "⚙️  Étape 3/5 : Exécution du post-déploiement..."
ssh $CPANEL_USER@$CPANEL_HOST << 'ENDSSH3'
cd /home/cp2639565p41/public_html
echo "  ➜ Dans : $(pwd)"

# Activer l'environnement virtuel
source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate

# Installer les dépendances
echo "  ➜ Installation des dépendances..."
pip install -r requirements.txt --quiet

# Appliquer les migrations
echo "  ➜ Application des migrations..."
python manage.py migrate --noinput

# Collecter les fichiers statiques
echo "  ➜ Collecte des fichiers statiques..."
python manage.py collectstatic --noinput --clear

echo "  ✅ Post-déploiement terminé"
ENDSSH3

echo ""

# Étape 4 : Corriger les permissions
echo "🔐 Étape 4/5 : Correction des permissions..."
ssh $CPANEL_USER@$CPANEL_HOST << 'ENDSSH4'
chmod -R 755 /home/cp2639565p41/public_html
chmod -R 755 /home/cp2639565p41/public_html/staticfiles 2>/dev/null || true
chmod -R 755 /home/cp2639565p41/public_html/media 2>/dev/null || true
echo "  ✅ Permissions corrigées"
ENDSSH4

echo ""

# Étape 5 : Redémarrer l'application
echo "🔄 Étape 5/5 : Redémarrage de l'application..."
ssh $CPANEL_USER@$CPANEL_HOST << 'ENDSSH5'
mkdir -p /home/cp2639565p41/public_html/tmp
touch /home/cp2639565p41/public_html/tmp/restart.txt
echo "  ✅ Application redémarrée"
ENDSSH5

echo ""
echo "=============================================="
echo "✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !"
echo "=============================================="
echo ""
echo "🌐 Votre site devrait être accessible à :"
echo "   https://aime-rdc.org"
echo ""
echo "📋 Vérifications à faire :"
echo "   1. Ouvrir https://aime-rdc.org dans votre navigateur"
echo "   2. Vérifier qu'il n'y a pas d'erreur 500"
echo "   3. Vérifier que les fichiers statiques chargent (CSS, images)"
echo "   4. Tester l'accès à l'admin : https://aime-rdc.org/admin"
echo ""
echo "🐛 En cas de problème, consulter les logs :"
echo "   ssh $CPANEL_USER@$CPANEL_HOST 'tail -n 50 ~/logs/error_log'"
echo ""
