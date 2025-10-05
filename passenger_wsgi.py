import os
import sys
import pymysql

# Configurer PyMySQL pour Django
pymysql.install_as_MySQLdb()

# Ajouter le chemin de votre projet Django
sys.path.insert(0, '/home/cp2639565p41/aime-rdc.org')

# Définir le module de configuration Django en production
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')

# Importer l'application WSGI Django
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
