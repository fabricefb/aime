#!/bin/bash

# Définition du chemin correct
SITE_PATH="/home/cp2639565p41/aime-rdc.org"

# Aller dans le répertoire du site
cd $SITE_PATH || {
    echo "❌ Erreur: Impossible d'accéder au dossier $SITE_PATH"
    exit 1
}

echo "🔄 Redémarrage du site AIME en cours..."

# 1. Activer l'environnement virtuel Python
source /home/cp2639565p41/virtualenv/aime-rdc.org/3.9/bin/activate || {
    echo "❌ Erreur: Impossible d'activer l'environnement virtuel"
    exit 1
}

# 2. Collecter les fichiers statiques
echo "📁 Collection des fichiers statiques..."
python3 manage.py collectstatic --noinput

# 3. Appliquer les migrations si nécessaire
echo "🗄️ Application des migrations..."
python3 manage.py migrate

# 4. Redémarrer Passenger (pour cPanel)
echo "🔄 Redémarrage de l'application..."
mkdir -p $SITE_PATH/tmp
touch $SITE_PATH/tmp/restart.txt

# 5. Vider le cache Django si configuré
echo "🧹 Nettoyage du cache..."
python3 manage.py collectstatic --clear --noinput
python3 manage.py collectstatic --noinput

echo "✅ Site redémarré avec succès !"
echo "🌐 Vos modifications sont maintenant visibles sur le site"