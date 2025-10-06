#!/bin/bash
# Script à copier-coller dans votre terminal SSH sur le serveur cPanel
# Connexion : ssh cp2639565p41@aime-rdc.org
# Ensuite, copiez-collez ce script complet

echo "🚀 DÉPLOIEMENT AIME - CORRECTIONS ERREUR 500"
echo "============================================="
echo ""
echo "📍 Serveur : $(hostname)"
echo "👤 Utilisateur : $(whoami)"
echo ""

# Vérification
if [ "$(whoami)" != "cp2639565p41" ]; then
    echo "⚠️  Attention : Vous devez être connecté en tant que cp2639565p41"
    echo "   Utilisateur actuel : $(whoami)"
    echo ""
    echo "   Connectez-vous avec : ssh cp2639565p41@aime-rdc.org"
    exit 1
fi

echo "✅ Utilisateur correct"
echo ""

# Variables
REPO_PATH="/home/cp2639565p41/repositories/aime"
DEPLOY_PATH="/home/cp2639565p41/public_html"
VENV_PATH="/home/cp2639565p41/virtualenv/public_html/3.9"

# Étape 1 : Pull depuis GitHub
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 ÉTAPE 1/6 : Pull depuis GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -d "$REPO_PATH" ]; then
    echo "❌ Erreur : Dépôt non trouvé à $REPO_PATH"
    exit 1
fi

cd "$REPO_PATH"
echo "📂 Dans : $(pwd)"
echo ""

echo "🔄 Git pull origin main..."
git pull origin main

if [ $? -eq 0 ]; then
    echo "✅ Pull réussi"
else
    echo "❌ Erreur lors du git pull"
    echo "   Vérifiez votre configuration SSH GitHub"
    exit 1
fi
echo ""

# Étape 2 : Copie des fichiers
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 ÉTAPE 2/6 : Copie des fichiers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📋 Copie de $REPO_PATH vers $DEPLOY_PATH..."
cp -R "$REPO_PATH"/* "$DEPLOY_PATH/"
cp "$REPO_PATH/.htaccess" "$DEPLOY_PATH/" 2>/dev/null || true

echo "✅ Fichiers copiés"
echo ""

# Étape 3 : Vérification des fichiers critiques
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 ÉTAPE 3/6 : Vérification des fichiers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$DEPLOY_PATH"

echo "Vérification de passenger_wsgi.py..."
if grep -q "public_html" passenger_wsgi.py; then
    echo "✅ passenger_wsgi.py : Chemin correct (public_html)"
else
    echo "⚠️  passenger_wsgi.py : Chemin peut-être incorrect"
fi

echo ""
echo "Vérification de .htaccess..."
if grep -q "virtualenv/public_html" .htaccess; then
    echo "✅ .htaccess : PassengerPython correct"
else
    echo "⚠️  .htaccess : PassengerPython peut-être incorrect"
fi

echo ""

# Étape 4 : Environnement virtuel et dépendances
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 ÉTAPE 4/6 : Installation des dépendances"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f "$VENV_PATH/bin/activate" ]; then
    echo "❌ Erreur : Environnement virtuel non trouvé"
    echo "   Chemin attendu : $VENV_PATH"
    echo ""
    echo "   🔧 Créez-le via cPanel :"
    echo "      1. Aller dans 'Setup Python App'"
    echo "      2. Créer app Python 3.9"
    echo "      3. Application root : /home/cp2639565p41/public_html"
    exit 1
fi

source "$VENV_PATH/bin/activate"
echo "✅ Environnement virtuel activé"
echo "🐍 Python : $(python --version)"
echo ""

echo "📦 Installation des dépendances..."
pip install -r requirements.txt --quiet

if [ $? -eq 0 ]; then
    echo "✅ Dépendances installées"
else
    echo "⚠️  Certaines dépendances ont échoué (on continue...)"
fi
echo ""

# Étape 5 : Migrations et statiques
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗄️  ÉTAPE 5/6 : Base de données et fichiers statiques"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔍 Vérification Django..."
python manage.py check

if [ $? -eq 0 ]; then
    echo "✅ Django configuration OK"
else
    echo "❌ Erreur de configuration Django"
    echo "   Consultez les erreurs ci-dessus"
fi
echo ""

echo "🗄️  Application des migrations..."
python manage.py migrate --noinput

if [ $? -eq 0 ]; then
    echo "✅ Migrations appliquées"
else
    echo "⚠️  Erreur lors des migrations (vérifiez la base de données)"
fi
echo ""

echo "📁 Collecte des fichiers statiques..."
python manage.py collectstatic --noinput --clear

if [ $? -eq 0 ]; then
    echo "✅ Fichiers statiques collectés"
else
    echo "⚠️  Erreur lors de collectstatic"
fi
echo ""

# Étape 6 : Permissions et redémarrage
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 ÉTAPE 6/6 : Permissions et redémarrage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔐 Correction des permissions..."
chmod -R 755 "$DEPLOY_PATH"
chmod -R 755 "$DEPLOY_PATH/staticfiles" 2>/dev/null || true
chmod -R 755 "$DEPLOY_PATH/media" 2>/dev/null || true
echo "✅ Permissions corrigées"
echo ""

echo "🔄 Redémarrage de l'application..."
mkdir -p "$DEPLOY_PATH/tmp"
touch "$DEPLOY_PATH/tmp/restart.txt"
echo "✅ Application redémarrée"
echo ""

# Résumé final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Site : https://aime-rdc.org"
echo ""
echo "📋 VÉRIFICATIONS À FAIRE :"
echo ""
echo "   1. Ouvrir https://aime-rdc.org dans votre navigateur"
echo "   2. Vérifier qu'il n'y a PAS d'erreur 500"
echo "   3. Vérifier que les CSS et images chargent"
echo "   4. Tester l'admin : https://aime-rdc.org/admin"
echo ""
echo "🔍 COMMANDE DE VÉRIFICATION RAPIDE :"
echo ""
echo "   curl -I https://aime-rdc.org"
echo ""
echo "   (Doit retourner 'HTTP/2 200' ou 'HTTP/1.1 200')"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🐛 EN CAS D'ERREUR 500 :"
echo ""
echo "   Consulter les logs :"
echo "   tail -n 50 ~/logs/error_log"
echo ""
echo "   Voir les erreurs WSGI :"
echo "   cat ~/public_html/wsgi_error.log"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 Déploiement terminé ! Vérifiez votre site maintenant !"
echo ""
