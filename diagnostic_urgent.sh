#!/bin/bash

SITE_PATH="/home/cp2639565p41/aime-rdc.org"
ERROR_LOG="/home/cp2639565p41/logs/aime-rdc.org_error_log"
PYTHON_VERSION="3.9"

echo "🔍 Diagnostic du site AIME RDC"
echo "==============================="

# 1. Vérifier les permissions du dossier
echo "📁 Vérification des permissions..."
ls -la $SITE_PATH
echo ""

# 2. Vérifier les dernières erreurs
echo "❌ Dernières erreurs du serveur..."
if [ -f "$ERROR_LOG" ]; then
    tail -n 50 $ERROR_LOG
else
    echo "Log non trouvé: $ERROR_LOG"
fi
echo ""

# 3. Vérifier l'environnement Python
echo "🐍 Configuration Python..."
source /home/cp2639565p41/virtualenv/aime-rdc.org/$PYTHON_VERSION/bin/activate
which python
python --version
pip list
echo ""

# 4. Vérifier la configuration Django
echo "🎯 Configuration Django..."
cd $SITE_PATH
python manage.py check
echo ""

# 5. Tester la base de données
echo "🗄️ Test de la base de données..."
python manage.py showmigrations
echo ""

# 6. Vérifier les fichiers essentiels
echo "📋 Fichiers essentiels..."
for file in passenger_wsgi.py manage.py aimesite/settings.py aimesite/wsgi.py; do
    if [ -f "$SITE_PATH/$file" ]; then
        echo "✅ $file existe"
    else
        echo "❌ $file MANQUANT!"
    fi
done
echo ""

# 7. Correction automatique des problèmes courants
echo "🔧 Application des corrections automatiques..."

# Recréer le dossier tmp
mkdir -p $SITE_PATH/tmp
chmod 755 $SITE_PATH/tmp

# Corriger les permissions
find $SITE_PATH -type d -exec chmod 755 {} \;
find $SITE_PATH -type f -exec chmod 644 {} \;
chmod 755 $SITE_PATH/manage.py
chmod 755 $SITE_PATH/passenger_wsgi.py
chmod -R 755 $SITE_PATH/staticfiles
chmod -R 755 $SITE_PATH/main/static

# Collecter les fichiers statiques
python manage.py collectstatic --noinput

# Redémarrer l'application
touch $SITE_PATH/tmp/restart.txt

echo "✅ Diagnostic terminé !
Pour résoudre l'erreur 500 :
1. Vérifiez les logs d'erreur ci-dessus
2. Assurez-vous que la base de données est configurée
3. Vérifiez que passenger_wsgi.py pointe vers la bonne configuration
4. Vérifiez les permissions des fichiers
5. Redémarrez l'application avec ./restart-site.sh"

# Désactiver l'environnement virtuel
deactivate