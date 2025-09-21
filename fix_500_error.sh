#!/bin/bash

# Configuration d'urgence pour résoudre l'erreur 500
SITE_PATH="/home/cp2639565p41/aime-rdc.org"

# Aller dans le répertoire du site
cd $SITE_PATH || {
    echo "❌ Erreur: Impossible d'accéder au dossier $SITE_PATH"
    exit 1
}

# 1. Activer l'environnement virtuel Python
source /home/cp2639565p41/virtualenv/aime-rdc.org/3.9/bin/activate || {
    echo "❌ Erreur: Impossible d'activer l'environnement virtuel"
    exit 1
}

# Créer une configuration debug pour Passenger
echo "# Configuration d'urgence pour debug
import os
import sys

# Ajout du chemin du site
INTERP = '/home/cp2639565p41/virtualenv/aime-rdc.org/3.9/bin/python3'
if sys.executable != INTERP:
    os.execl(INTERP, INTERP, *sys.argv)

# Définir le chemin du site
cwd = os.getcwd()
sys.path.append(cwd)
sys.path.append(cwd + '/aimesite')

# Configuration debug pour Passenger
os.environ['DJANGO_SETTINGS_MODULE'] = 'aimesite.debug_settings'

# Désactiver le buffering de stdout
sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', buffering=1)

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()" > $SITE_PATH/passenger_wsgi_debug.py

# Faire une copie de sauvegarde du fichier original
cp $SITE_PATH/passenger_wsgi.py $SITE_PATH/passenger_wsgi.py.backup

# Remplacer par la configuration debug
cp $SITE_PATH/passenger_wsgi_debug.py $SITE_PATH/passenger_wsgi.py

# Donner les permissions
chmod 755 $SITE_PATH/passenger_wsgi.py

# Redémarrer l'application
touch $SITE_PATH/tmp/restart.txt

echo "✅ Configuration debug appliquée.
🔍 Vérifiez le site maintenant. Si l'erreur 500 persiste :
1. Regardez les logs : tail -f ~/logs/aime-rdc.org_error_log
2. Exécutez ./diagnostic_urgent.sh pour plus de détails
3. Pour restaurer : mv passenger_wsgi.py.backup passenger_wsgi.py"

# Désactiver l'environnement virtuel
deactivate