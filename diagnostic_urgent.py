#!/home/cp2639565p41/virtualenv/aime-rdc/bin/python
"""
Script de diagnostic urgent pour erreur 500 persistante
Active DEBUG temporairement pour voir l'erreur exacte
"""

import os
import sys
import subprocess

print("=== DIAGNOSTIC URGENT ERREUR 500 ===")

# 1. Vérification de base
print("\n1. === VÉRIFICATION ENVIRONNEMENT ===")
print(f"Python: {sys.version}")
print(f"Répertoire: {os.getcwd()}")

# Aller dans le bon répertoire
os.chdir('/home/cp2639565p41/aime-rdc/')

# 2. Test Django de base
print("\n2. === TEST DJANGO DE BASE ===")
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')

try:
    import django
    django.setup()
    print("✅ Django setup OK")
    
    from django.conf import settings
    print(f"DEBUG: {settings.DEBUG}")
    print(f"DATABASES: {settings.DATABASES['default']['NAME']}")
    
except Exception as e:
    print(f"❌ Erreur Django setup: {e}")
    import traceback
    traceback.print_exc()

# 3. Test de connexion DB
print("\n3. === TEST BASE DE DONNÉES ===")
try:
    from django.db import connection
    cursor = connection.cursor()
    cursor.execute("SELECT 1")
    print("✅ Base de données connectée")
except Exception as e:
    print(f"❌ Erreur DB: {e}")
    import traceback
    traceback.print_exc()

# 4. Test des migrations
print("\n4. === VÉRIFICATION MIGRATIONS ===")
try:
    result = subprocess.run([
        'python', 'manage.py', 'showmigrations', 
        '--settings=aimesite.production_settings'
    ], capture_output=True, text=True)
    
    if 'UNAPPLIED' in result.stdout:
        print("❌ MIGRATIONS NON APPLIQUÉES DÉTECTÉES!")
        print(result.stdout)
    else:
        print("✅ Migrations appliquées")
        
except Exception as e:
    print(f"❌ Erreur vérification migrations: {e}")

# 5. Test des modèles
print("\n5. === TEST MODÈLES ===")
try:
    from main.models import MutotoBikeChallenge
    count = MutotoBikeChallenge.objects.count()
    print(f"✅ MutotoBikeChallenge: {count} objets")
except Exception as e:
    print(f"❌ Erreur modèle MBC: {e}")
    import traceback
    traceback.print_exc()

# 6. Test direct des vues
print("\n6. === TEST VUES DIRECTES ===")
try:
    from django.test import Client
    client = Client()
    
    # Test page d'accueil
    response = client.get('/')
    print(f"Page d'accueil: {response.status_code}")
    
    # Test MBC
    response = client.get('/mbc/')
    print(f"Page MBC: {response.status_code}")
    if response.status_code == 500:
        print("❌ ERREUR 500 CONFIRMÉE sur /mbc/")
    
except Exception as e:
    print(f"❌ Erreur test vues: {e}")
    import traceback
    traceback.print_exc()

print("\n=== CRÉATION SETTINGS DEBUG ===")
# Créer un fichier settings de debug
debug_settings = '''# Settings debug temporaire pour diagnostiquer erreur 500
from .settings import *
import pymysql

# Configure PyMySQL
pymysql.install_as_MySQLdb()

# ACTIVATION DEBUG
DEBUG = True
ALLOWED_HOSTS = ['*']

# Base de données (copie de production_settings)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'cp2639565p41_aimer2639565',
        'USER': 'cp2639565p41_aimer2639565',
        'PASSWORD': 'Wazenga007@bd',
        'HOST': 'localhost',
        'PORT': '3306',
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
        },
    }
}

# Fichiers statiques
STATIC_URL = '/static/'
STATIC_ROOT = '/home/cp2639565p41/aime-rdc/staticfiles/'
MEDIA_URL = '/media/'
MEDIA_ROOT = '/home/cp2639565p41/aime-rdc/media/'

print("⚠️ MODE DEBUG ACTIVÉ TEMPORAIREMENT")
'''

with open('aimesite/debug_urgent.py', 'w') as f:
    f.write(debug_settings)

print("✅ Fichier debug_urgent.py créé")

print("\n=== CRÉATION PASSENGER DEBUG ===")
# Créer passenger_wsgi en mode debug
passenger_debug = '''#!/home/cp2639565p41/virtualenv/aime-rdc/bin/python
import sys
import os
import pymysql

pymysql.install_as_MySQLdb()

sys.path.insert(0, '/home/cp2639565p41/aime-rdc')
sys.path.insert(0, os.path.dirname(__file__))

# UTILISER DEBUG SETTINGS
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.debug_urgent')

print("🔍 MODE DEBUG ACTIVÉ - VOUS VERREZ L'ERREUR DÉTAILLÉE")

try:
    from django.core.wsgi import get_wsgi_application
    application = get_wsgi_application()
    print("✅ Application Django chargée en mode debug")
except Exception as e:
    print(f"❌ Erreur: {e}")
    import traceback
    traceback.print_exc()
    raise
'''

# Sauvegarder l'ancien et créer le nouveau
if os.path.exists('passenger_wsgi.py'):
    os.rename('passenger_wsgi.py', 'passenger_wsgi_backup_urgent.py')

with open('passenger_wsgi.py', 'w') as f:
    f.write(passenger_debug)

os.chmod('passenger_wsgi.py', 0o755)
print("✅ passenger_wsgi.py en mode debug créé")

print("\n=== INSTRUCTIONS URGENTES ===")
print("1. Redémarrer immédiatement:")
print("   touch tmp/restart.txt")
print("2. Aller sur votre site:")
print("   https://aime-rdc.org/")
print("3. VOUS VERREZ L'ERREUR DÉTAILLÉE au lieu de 'Server Error (500)'")
print("4. Copier-coller l'erreur complète qui s'affiche")
print("5. Une fois le diagnostic fait, restaurer:")
print("   mv passenger_wsgi_backup_urgent.py passenger_wsgi.py")
print("   rm aimesite/debug_urgent.py")

print("\n⚠️ ATTENTION: Mode debug actif, ne pas laisser en production!")
print("=== FIN DIAGNOSTIC ===")
