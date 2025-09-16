#!/usr/bin/env python
import sys
import os
import pymysql

# Configure PyMySQL pour Django
pymysql.install_as_MySQLdb()

# Debug: afficher les informations essentielles
print("✓ Python version:", sys.version.split()[0])
print("✓ Working directory:", os.getcwd())

# Ajouter les chemins nécessaires
# Remplacer 'yourusername' par votre nom d'utilisateur cPanel
sys.path.insert(0, '/home/cp2639565p41/aime-rdc.org')
sys.path.insert(0, os.path.dirname(__file__))

# Définir le module de settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')

try:
    # Importer et créer l'application WSGI
    from django.core.wsgi import get_wsgi_application
    application = get_wsgi_application()
    print("Django application loaded successfully!")
except Exception as e:
    print(f"Error loading Django application: {e}")
    import traceback
    traceback.print_exc()
    raise
