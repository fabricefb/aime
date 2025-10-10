#!/bin/bash
# Script de correction d'urgence pour erreur 403 Forbidden
# À exécuter sur le serveur : bash fix-403.sh

echo "🔧 CORRECTION ERREUR 403 FORBIDDEN"
echo "===================================="
echo ""

# Variables
DEPLOY_PATH="/home/cp2639565p41/public_html"

cd "$DEPLOY_PATH" || exit 1

echo "📍 Dans : $(pwd)"
echo ""

# Sauvegarde
echo "💾 Sauvegarde des fichiers actuels..."
cp passenger_wsgi.py passenger_wsgi.py.backup 2>/dev/null || true
cp .htaccess .htaccess.backup 2>/dev/null || true
echo "✅ Sauvegarde créée"
echo ""

# Correction du passenger_wsgi.py
echo "🔧 Correction de passenger_wsgi.py..."
cat > passenger_wsgi.py << 'EOF'
#!/usr/bin/env python
import sys
import os

# Chemins critiques pour cPanel - CORRIGÉS
CPANEL_USER = 'cp2639565p41'
PROJECT_DIR = f'/home/{CPANEL_USER}/public_html'
VIRTUALENV_PATH = f'/home/{CPANEL_USER}/virtualenv/public_html/3.9'

# Ajouter le chemin du projet
if PROJECT_DIR not in sys.path:
    sys.path.insert(0, PROJECT_DIR)

# Ajouter le virtualenv au path
sys.path.insert(0, f'{VIRTUALENV_PATH}/lib/python3.9/site-packages')

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')

# Import PyMySQL pour MySQL
try:
    import pymysql
    pymysql.install_as_MySQLdb()
except ImportError:
    pass

# Créer l'application WSGI
try:
    from django.core.wsgi import get_wsgi_application
    application = get_wsgi_application()
except Exception as e:
    # Log l'erreur dans un fichier accessible
    with open(f'/home/{CPANEL_USER}/public_html/wsgi_error.log', 'w') as f:
        import traceback
        f.write(f"WSGI Error: {e}\n")
        f.write(traceback.format_exc())
    raise
EOF

echo "✅ passenger_wsgi.py corrigé"
echo ""

# Correction du .htaccess
echo "🔧 Correction de .htaccess..."
cat > .htaccess << 'EOF'
# Configuration Apache pour Django - AIME Website
PassengerPython /home/cp2639565p41/virtualenv/public_html/3.9/bin/python
PassengerEnabled On
PassengerAppRoot /home/cp2639565p41/public_html

Options -MultiViews
RewriteEngine On

# Redirection www vers non-www
RewriteCond %{HTTP_HOST} ^www\.aime-rdc\.org [NC]
RewriteRule ^(.*)$ https://aime-rdc.org/$1 [L,R=301]

# Servir les fichiers statiques directement
RewriteRule ^static/(.*)$ staticfiles/$1 [L]
RewriteRule ^media/(.*)$ media/$1 [L]

# Configuration pour Django
RewriteCond %{REQUEST_URI} !^/static/
RewriteCond %{REQUEST_URI} !^/media/
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ passenger_wsgi.py/$1 [QSA,L]

# Autoriser passenger_wsgi.py
<Files "passenger_wsgi.py">
    Require all granted
</Files>

# Protection des fichiers sensibles
<FilesMatch "\.(py|pyc)$">
    <Files "!passenger_wsgi.py">
        Require all denied
    </Files>
</FilesMatch>

<Files "db.sqlite3">
    Require all denied
</Files>
EOF

echo "✅ .htaccess corrigé"
echo ""

# Correction des permissions
echo "🔐 Correction des permissions..."
chmod 644 passenger_wsgi.py
chmod 644 .htaccess
chmod 755 "$DEPLOY_PATH"
chmod -R 755 staticfiles 2>/dev/null || true
chmod -R 755 media 2>/dev/null || true

echo "✅ Permissions corrigées"
echo ""

# Redémarrage
echo "🔄 Redémarrage de l'application..."
mkdir -p tmp
touch tmp/restart.txt

echo "✅ Application redémarrée"
echo ""

# Vérification
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CORRECTIONS APPLIQUÉES !"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔍 Vérification des chemins corrigés :"
echo ""
echo "passenger_wsgi.py :"
grep "PROJECT_DIR" passenger_wsgi.py
grep "VIRTUALENV_PATH" passenger_wsgi.py
echo ""
echo ".htaccess :"
grep "PassengerPython" .htaccess | head -1
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏰ Attendez 10-15 secondes puis testez :"
echo "   https://aime-rdc.org"
echo ""
echo "🐛 Si encore erreur, consultez les logs :"
echo "   tail -n 50 ~/logs/error_log"
echo "   cat ~/public_html/wsgi_error.log"
echo ""
echo "💾 Fichiers de sauvegarde créés :"
echo "   passenger_wsgi.py.backup"
echo "   .htaccess.backup"
echo ""
