#!/home/cp2639565p41/virtualenv/aime-rdc/bin/python
"""
Script pour corriger les problèmes d'images et fichiers statiques
À exécuter sur le serveur
"""

import os
import sys
import shutil

# Ajouter les chemins
sys.path.insert(0, '/home/cp2639565p41/aime-rdc')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.production_settings')

import django
django.setup()

from django.conf import settings
from django.core.management import call_command

print("=== CORRECTION DES FICHIERS STATIQUES ===")

# 1. Créer les répertoires nécessaires
static_root = '/home/cp2639565p41/aime-rdc/staticfiles/'
media_root = '/home/cp2639565p41/aime-rdc/media/'

print(f"1. Création des répertoires...")
os.makedirs(static_root, exist_ok=True)
os.makedirs(media_root, exist_ok=True)
print(f"✓ Répertoires créés: {static_root} et {media_root}")

# 2. Collecter les fichiers statiques
print(f"2. Collection des fichiers statiques...")
try:
    call_command('collectstatic', '--noinput', verbosity=1)
    print("✓ Fichiers statiques collectés")
except Exception as e:
    print(f"✗ Erreur collectstatic: {e}")

# 3. Vérifier les images du projet
print(f"3. Vérification des images...")
images_dirs = [
    '/home/cp2639565p41/aime-rdc/main/static/main/images/',
    '/home/cp2639565p41/aime-rdc/staticfiles/main/images/',
]

for img_dir in images_dirs:
    if os.path.exists(img_dir):
        images = [f for f in os.listdir(img_dir) if f.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.svg'))]
        print(f"✓ Trouvé {len(images)} images dans {img_dir}")
        if 'logo-aime.png' in images:
            print("✓ Logo AIME trouvé!")
    else:
        print(f"✗ Répertoire non trouvé: {img_dir}")

# 4. Vérifier les permissions
print(f"4. Vérification des permissions...")
try:
    os.chmod(static_root, 0o755)
    os.chmod(media_root, 0o755)
    print("✓ Permissions corrigées")
except Exception as e:
    print(f"✗ Erreur permissions: {e}")

# 5. Test d'accès aux URLs statiques
print(f"5. Configuration URLs:")
print(f"STATIC_URL: {settings.STATIC_URL}")
print(f"STATIC_ROOT: {settings.STATIC_ROOT}")
print(f"MEDIA_URL: {settings.MEDIA_URL}")
print(f"MEDIA_ROOT: {settings.MEDIA_ROOT}")

print("=== CORRECTION TERMINÉE ===")
print("Pensez à redémarrer Passenger: touch /home/cp2639565p41/aime-rdc/tmp/restart.txt")
