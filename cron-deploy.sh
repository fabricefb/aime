#!/bin/bash
# Script à exécuter via cron

# Configuration
SITE_PATH="/home/cp2639565p41/aime-rdc"
LOG_FILE="/home/cp2639565p41/cron-deployment.log"

# Fonction de journalisation
log() {
    echo "$(date): $1" >> $LOG_FILE
}

# Aller dans le répertoire du projet
cd $SITE_PATH

# Vérifier les mises à jour
log "Vérification des mises à jour..."
git fetch origin

# Si des mises à jour sont disponibles
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
    log "Nouvelles mises à jour détectées, déploiement en cours..."
    
    # Tirer les changements
    git pull origin main >> $LOG_FILE 2>&1
    
    # Installer les dépendances
    pip3 install -r requirements.txt >> $LOG_FILE 2>&1
    
    # Collecter les fichiers statiques
    python3 manage.py collectstatic --noinput >> $LOG_FILE 2>&1
    
    # Appliquer les migrations
    python3 manage.py migrate --noinput >> $LOG_FILE 2>&1
    
    # Redémarrer l'application
    touch tmp/restart.txt
    
    log "Déploiement terminé avec succès"
else
    log "Aucune mise à jour disponible"
fi