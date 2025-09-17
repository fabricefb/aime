#!/bin/bash

echo "🔄 Redémarrage du site AIME en cours..."

# 1. Collecter les fichiers statiques
echo "📁 Collection des fichiers statiques..."
python3 manage.py collectstatic --noinput

# 2. Appliquer les migrations si nécessaire
echo "🗄️ Application des migrations..."
python3 manage.py migrate

# 3. Redémarrer Passenger (pour cPanel)
echo "🔄 Redémarrage de l'application..."
touch tmp/restart.txt
mkdir -p tmp
touch tmp/restart.txt

# 4. Vider le cache Django si configuré
echo "🧹 Nettoyage du cache..."
python3 manage.py collectstatic --clear --noinput
python3 manage.py collectstatic --noinput

echo "✅ Site redémarré avec succès !"
echo "🌐 Vos modifications sont maintenant visibles sur le site"