#!/bin/bash
echo "Début du déploiement..."

# Configuration
REMOTE_USER="cp2639565p41"
REMOTE_HOST="your-cpanel-server.com"  # Remplacez par votre serveur cPanel
REMOTE_PATH="/home/cp2639565p41/aime-rdc"
REPO_URL="git@github.com:fabricefb/aime.git"

# Connexion SSH et exécution des commandes de déploiement
ssh $REMOTE_USER@$REMOTE_HOST << 'ENDSSH'
    cd $REMOTE_PATH
    
    # Récupérer les dernières modifications
    git pull origin main
    
    # Installer/mettre à jour les dépendances Python
    pip3 install -r requirements.txt
    
    # Collecter les fichiers statiques
    python3 manage.py collectstatic --noinput
    
    # Appliquer les migrations
    python3 manage.py migrate --noinput
    
    # Redémarrer l'application
    touch tmp/restart.txt
    
    echo "Déploiement terminé !"
ENDSSH