#!/bin/bash
# Ce script doit être placé sur le serveur cPanel

# Journal des déploiements
LOG_FILE="/home/cp2639565p41/deployment.log"

echo "$(date): Début du déploiement" >> $LOG_FILE

# Aller dans le répertoire du projet
cd /home/cp2639565p41/aime-rdc

# Récupérer les modifications
git pull origin main >> $LOG_FILE 2>&1

# Installer les dépendances
pip3 install -r requirements.txt >> $LOG_FILE 2>&1

# Collecter les fichiers statiques
python3 manage.py collectstatic --noinput >> $LOG_FILE 2>&1

# Appliquer les migrations
python3 manage.py migrate --noinput >> $LOG_FILE 2>&1

# Redémarrer l'application
touch tmp/restart.txt

echo "$(date): Fin du déploiement" >> $LOG_FILE