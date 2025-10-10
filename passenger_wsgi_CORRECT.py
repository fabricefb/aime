#!/usr/bin/env python
import sys
import os

# Chemins critiques pour cPanel - CORRIGÉS
CPANEL_USER = 'cp2639565p41'
PROJECT_DIR = f'/home/{CPANEL_USER}/public_html'  # ✅ CORRIGÉ : pas /aimesite
VIRTUALENV_PATH = f'/home/{CPANEL_USER}/virtualenv/public_html/3.9'  # ✅ CORRIGÉ : pas repositories/aime

# Ajouter le chemin du projet
if PROJECT_DIR not in sys.path:
    sys.path.insert(0, PROJECT_DIR)

# Ajouter le virtualenv au path
sys.path.insert(0, f'{VIRTUALENV_PATH}/lib/python3.9/site-packages')

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')  # ✅ CORRIGÉ : production_settings

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
