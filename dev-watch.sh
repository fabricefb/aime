#!/bin/bash

# Définition du chemin correct
SITE_PATH="/home/cp2639565p41/aime-rdc.org"

# Aller dans le répertoire du site
cd $SITE_PATH || {
    echo "❌ Erreur: Impossible d'accéder au dossier $SITE_PATH"
    exit 1
}

echo "🚀 Mode développement AIME - Auto-reload activé"

# 1. Activer l'environnement virtuel Python
source /home/cp2639565p41/virtualenv/aime-rdc.org/3.9/bin/activate || {
    echo "❌ Erreur: Impossible d'activer l'environnement virtuel"
    exit 1
}

# Configuration pour le développement
export DJANGO_SETTINGS_MODULE=aimesite.debug_settings

# Surveiller les changements et redémarrer automatiquement
echo "👀 Surveillance des fichiers activée..."
echo "📝 Modifiez vos fichiers et le site se mettra à jour automatiquement"
echo "🛑 Appuyez sur Ctrl+C pour arrêter"

while true; do
    echo "🔄 $(date): Rechargement des fichiers statiques..."
    python3 manage.py collectstatic --noinput --clear > /dev/null 2>&1
    mkdir -p $SITE_PATH/tmp
    touch $SITE_PATH/tmp/restart.txt
    chmod -R 755 $SITE_PATH/staticfiles/
    chmod -R 755 $SITE_PATH/main/static/
    echo "✅ $(date): Site mis à jour"
    sleep 30  # Attendre 30 secondes avant le prochain rechargement
done

# Désactiver l'environnement virtuel à la sortie
trap "deactivate" EXIT