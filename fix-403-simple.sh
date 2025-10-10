#!/bin/bash
# Script de correction simplifiée - sans git pull
# À exécuter directement dans public_html

echo "🔧 CORRECTION ERREUR 403 FORBIDDEN"
echo "===================================="
echo ""

# Variables
DEPLOY_PATH="/home/cp2639565p41/public_html"
REPO_PATH="/home/cp2639565p41/repositories/aime"

cd "$DEPLOY_PATH" || exit 1

echo "📍 Dans : $(pwd)"
echo ""

# Vérifier si le dépôt existe
if [ ! -d "$REPO_PATH" ]; then
    echo "❌ Dépôt non trouvé : $REPO_PATH"
    echo "   Création du dossier..."
    mkdir -p "$REPO_PATH"
    cd "$REPO_PATH"
    git clone https://github.com/fabricefb/aime.git .
    cd "$DEPLOY_PATH"
fi

# Pull les dernières modifications dans le dépôt
echo "📥 Mise à jour du dépôt Git..."
cd "$REPO_PATH"
git pull origin main || echo "⚠️  Git pull échoué, on continue..."

# Copier les fichiers depuis le dépôt
echo ""
echo "📁 Copie des fichiers corrigés depuis le dépôt..."
cp -f "$REPO_PATH/passenger_wsgi.py" "$DEPLOY_PATH/passenger_wsgi.py"
cp -f "$REPO_PATH/.htaccess" "$DEPLOY_PATH/.htaccess"
cp -f "$REPO_PATH/fix-403.sh" "$DEPLOY_PATH/fix-403.sh" 2>/dev/null || true

cd "$DEPLOY_PATH"

echo "✅ Fichiers copiés"
echo ""

# Sauvegarde
echo "💾 Sauvegarde des fichiers actuels..."
cp passenger_wsgi.py passenger_wsgi.py.backup 2>/dev/null || true
cp .htaccess .htaccess.backup 2>/dev/null || true
echo "✅ Sauvegarde créée"
echo ""

# Vérification et affichage des chemins
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Vérification des chemins dans passenger_wsgi.py :"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
grep "PROJECT_DIR\|VIRTUALENV_PATH" passenger_wsgi.py | head -2
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Vérification de .htaccess :"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
grep "PassengerPython\|PassengerEnabled" .htaccess | head -3
echo ""

# Correction des permissions
echo "🔐 Correction des permissions..."
chmod 644 passenger_wsgi.py
chmod 644 .htaccess
chmod 755 "$DEPLOY_PATH"
chmod -R 755 staticfiles 2>/dev/null || true
chmod -R 755 media 2>/dev/null || true

echo "✅ Permissions corrigées"
echo ""

# Redémarrage
echo "🔄 Redémarrage de l'application..."
mkdir -p tmp
touch tmp/restart.txt

echo "✅ Application redémarrée"
echo ""

# Résumé final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CORRECTIONS APPLIQUÉES !"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏰ Attendez 10-15 secondes puis testez :"
echo "   https://aime-rdc.org"
echo ""
echo "🐛 Si erreur persiste, consultez les logs :"
echo "   tail -n 50 ~/logs/error_log"
echo "   cat ~/public_html/wsgi_error.log"
echo ""
