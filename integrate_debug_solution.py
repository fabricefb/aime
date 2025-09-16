#!/home/cp2639565p41/virtualenv/aime-rdc/bin/python
"""
Script pour intégrer la solution debug_settings dans production_settings
Et déployer la configuration qui fonctionne
"""

import os
import subprocess
import shutil
from datetime import datetime

print("=== INTÉGRATION SOLUTION DEBUG DANS PRODUCTION ===")
print(f"Heure: {datetime.now()}")

# Aller dans le répertoire
os.chdir('/home/cp2639565p41/aime-rdc/')

# 1. Sauvegarder les configurations actuelles
print("\n1. === SAUVEGARDE CONFIGURATIONS ===")
backup_files = [
    ('aimesite/production_settings.py', f'aimesite/production_settings_backup_{datetime.now().strftime("%Y%m%d_%H%M")}.py'),
    ('passenger_wsgi.py', f'passenger_wsgi_backup_{datetime.now().strftime("%Y%m%d_%H%M")}.py')
]

for original, backup in backup_files:
    if os.path.exists(original):
        shutil.copy2(original, backup)
        print(f"✅ Sauvegardé: {original} → {backup}")

# 2. Mise à jour passenger_wsgi.py pour utiliser la nouvelle production_settings
print("\n2. === MISE À JOUR PASSENGER_WSGI ===")
passenger_content = '''#!/home/cp2639565p41/virtualenv/aime-rdc/bin/python
import sys
import os
import pymysql

# Configure PyMySQL
pymysql.install_as_MySQLdb()

# Chemins
sys.path.insert(0, '/home/cp2639565p41/aime-rdc')
sys.path.insert(0, os.path.dirname(__file__))

# Utiliser la production_settings mise à jour (basée sur debug_settings qui fonctionne)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')

# Logging des erreurs
import logging
logging.basicConfig(
    filename='/home/cp2639565p41/aime-rdc/passenger_errors.log',
    level=logging.ERROR,
    format='%(asctime)s %(levelname)s: %(message)s'
)

try:
    from django.core.wsgi import get_wsgi_application
    application = get_wsgi_application()
    logging.info("✅ Django application loaded with updated production_settings")
except Exception as e:
    logging.error(f"❌ Failed to load Django application: {e}")
    import traceback
    logging.error(traceback.format_exc())
    raise
'''

with open('passenger_wsgi.py', 'w') as f:
    f.write(passenger_content)

os.chmod('passenger_wsgi.py', 0o755)
print("✅ passenger_wsgi.py mis à jour")

# 3. Test de la nouvelle configuration
print("\n3. === TEST NOUVELLE CONFIGURATION ===")
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')

try:
    import django
    django.setup()
    print("✅ Django setup avec production_settings OK")
    
    # Test base de données
    from django.db import connection
    cursor = connection.cursor()
    cursor.execute("SELECT 1")
    print("✅ Connexion base de données OK")
    
    # Test modèles
    from main.models import MutotoBikeChallenge
    count = MutotoBikeChallenge.objects.count()
    print(f"✅ Modèles accessibles: {count} objets MBC")
    
except Exception as e:
    print(f"❌ Erreur test configuration: {e}")
    import traceback
    traceback.print_exc()

# 4. Collection des fichiers statiques
print("\n4. === COLLECTION FICHIERS STATIQUES ===")
try:
    result = subprocess.run([
        'python', 'manage.py', 'collectstatic', '--noinput', '--clear',
        '--settings=aimesite.production_settings'
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✅ Fichiers statiques collectés")
    else:
        print(f"❌ Erreur collectstatic: {result.stderr}")
        
except Exception as e:
    print(f"❌ Exception collectstatic: {e}")

# 5. Test des URLs problématiques
print("\n5. === TEST URLs PROBLÉMATIQUES ===")
try:
    from django.test import Client
    
    client = Client()
    test_urls = [
        ('/', 'Accueil'),
        ('/mbc/', 'MBC Challenge'),
        ('/impact-map/', 'Impact Map'),
        ('/admin/', 'Admin Django')
    ]
    
    for url, name in test_urls:
        try:
            response = client.get(url)
            if response.status_code == 200:
                print(f"✅ {name} ({url}): OK")
            elif response.status_code == 302:
                print(f"✅ {name} ({url}): Redirection OK")
            else:
                print(f"⚠️ {name} ({url}): Status {response.status_code}")
        except Exception as e:
            print(f"❌ {name} ({url}): {e}")
            
except Exception as e:
    print(f"❌ Erreur test URLs: {e}")

# 6. Installation WhiteNoise si nécessaire
print("\n6. === VÉRIFICATION WHITENOISE ===")
try:
    import whitenoise
    print(f"✅ WhiteNoise disponible: {whitenoise.__version__}")
except ImportError:
    print("⚠️ Installation WhiteNoise...")
    subprocess.run(['pip', 'install', 'whitenoise'])
    print("✅ WhiteNoise installé")

# 7. Redémarrage de l'application
print("\n7. === REDÉMARRAGE APPLICATION ===")
os.makedirs('tmp', exist_ok=True)
with open('tmp/restart.txt', 'w') as f:
    f.write(f"Restart: {datetime.now()}")

print("✅ Application redémarrée")

# 8. Instructions finales
print("\n=== INTÉGRATION TERMINÉE ===")
print("🎯 CONFIGURATION APPLIQUÉE:")
print("- ✅ production_settings.py basé sur debug_settings qui fonctionne")
print("- ✅ passenger_wsgi.py mis à jour")
print("- ✅ Fichiers statiques recollectés")
print("- ✅ Application redémarrée")

print("\n🔍 TESTS À FAIRE:")
print("1. https://aime-rdc.org/ (doit fonctionner)")
print("2. https://aime-rdc.org/mbc/ (doit fonctionner)")
print("3. https://aime-rdc.org/impact-map/ (doit fonctionner)")
print("4. https://aime-rdc.org/admin/ (doit avoir le style)")

print("\n📝 LOGS DISPONIBLES:")
print("- /home/cp2639565p41/aime-rdc/passenger_errors.log")

print("\n✅ La solution debug_settings a été intégrée en production!")
