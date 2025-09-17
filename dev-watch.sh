#!/bin/bash

echo "🚀 Mode développement AIME - Auto-reload activé"

# Configuration pour le développement
export DJANGO_SETTINGS_MODULE=aimesite.debug_settings

# Surveiller les changements et redémarrer automatiquement
echo "👀 Surveillance des fichiers activée..."
echo "📝 Modifiez vos fichiers et le site se mettra à jour automatiquement"
echo "🛑 Appuyez sur Ctrl+C pour arrêter"

while true; do
    echo "🔄 $(date): Rechargement des fichiers statiques..."
    python3 manage.py collectstatic --noinput --clear > /dev/null 2>&1
    touch tmp/restart.txt
    echo "✅ $(date): Site mis à jour"
    sleep 30  # Attendre 30 secondes avant le prochain rechargement
done