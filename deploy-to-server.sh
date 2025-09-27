#!/bin/bash

# Configuration
CPANEL_USER="cp2639565p41"
SITE_PATH="/home/cp2639565p41/public_html"
HOST="aime-rdc.org"
PYTHON_ENV="/home/cp2639565p41/virtualenv/public_html/3.9/bin/activate"

echo "🚀 Début du déploiement..."

# Vérification du répertoire de destination
ssh $CPANEL_USER@$HOST "if [ ! -d $SITE_PATH ]; then mkdir -p $SITE_PATH; fi"

# Synchronisation des fichiers
echo "📂 Synchronisation des fichiers..."
rsync -avz --progress --exclude '.git/' \
    --exclude '.vscode/' \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude 'venv/' \
    --exclude 'env/' \
    ./ $CPANEL_USER@$HOST:$SITE_PATH/

# Exécution des commandes sur le serveur
ssh $CPANEL_USER@$HOST << EOF
    cd $SITE_PATH
    source $PYTHON_ENV
    
    # Installation/mise à jour des dépendances
    pip install -r requirements.txt
    
    # Collecte des fichiers statiques
    python manage.py collectstatic --noinput
    
    # Application des migrations
    python manage.py migrate --noinput
    
    # Redémarrage de l'application
    touch tmp/restart.txt
    
    # Correction des permissions
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chmod +x manage.py
    chmod +x *.sh
    chmod -R 755 staticfiles/
EOF

echo "✅ Déploiement terminé avec succès !"