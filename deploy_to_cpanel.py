#!/usr/bin/env python3
"""
Script de déploiement automatique pour cPanel
AIME RDC - Version production
"""

import os
import shutil
import subprocess
import zipfile
from pathlib import Path

def create_deployment_package():
    """Crée un package de déploiement pour cPanel"""
    
    print("🚀 Création du package de déploiement AIME pour cPanel...")
    
    # Dossier de déploiement
    deploy_dir = Path("deployment_package")
    if deploy_dir.exists():
        shutil.rmtree(deploy_dir)
    deploy_dir.mkdir()
    
    # Files et dossiers à inclure
    files_to_include = [
        "aimesite/",
        "main/",
        "staticfiles/",
        "manage.py",
        "passenger_wsgi.py",
        "requirements.txt",
        "db.sqlite3",  # Base de données de développement (optionnelle)
    ]
    
    # Copier les fichiers
    for item in files_to_include:
        src = Path(item)
        if src.exists():
            if src.is_dir():
                shutil.copytree(src, deploy_dir / item, ignore=ignore_files)
                print(f"✅ Copié: {item}/")
            else:
                shutil.copy2(src, deploy_dir / item)
                print(f"✅ Copié: {item}")
        else:
            print(f"⚠️  Non trouvé: {item}")
    
    # Créer le fichier .htaccess pour cPanel
    create_htaccess(deploy_dir)
    
    # Créer les instructions de déploiement
    create_deployment_instructions(deploy_dir)
    
    # Créer l'archive ZIP
    create_zip_archive(deploy_dir)
    
    print(f"\n🎉 Package créé dans: {deploy_dir.absolute()}")
    print("📦 Archive ZIP créée: deployment_package.zip")

def ignore_files(dir, files):
    """Ignore les fichiers non nécessaires"""
    ignore_patterns = {
        '__pycache__',
        '*.pyc',
        '*.pyo',
        '.git',
        '.gitignore',
        '.env',
        'venv',
        'env',
        '.vscode',
        'node_modules',
        '*.log',
        '.pytest_cache',
        'tmp'
    }
    return [f for f in files if f in ignore_patterns or f.startswith('.')]

def create_htaccess(deploy_dir):
    """Crée le fichier .htaccess pour cPanel"""
    htaccess_content = """RewriteEngine On
RewriteCond %{REQUEST_URI} !^/static/
RewriteCond %{REQUEST_URI} !^/media/
RewriteRule ^(.*)$ /passenger_wsgi.py/$1 [QSA,L]

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Security headers
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
</IfModule>

# Cache static files
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
</IfModule>
"""
    
    with open(deploy_dir / ".htaccess", "w") as f:
        f.write(htaccess_content)
    print("✅ Créé: .htaccess")

def create_deployment_instructions(deploy_dir):
    """Crée les instructions de déploiement"""
    instructions = """
INSTRUCTIONS DE DÉPLOIEMENT AIME RDC - cPanel
=============================================

📋 PRÉREQUIS:
1. Accès cPanel avec Python 3.9 activé
2. Base de données MySQL configurée
3. Domaine pointé vers le dossier public_html

🚀 ÉTAPES DE DÉPLOIEMENT:

1. UPLOAD DES FICHIERS:
   - Décompresser le contenu de ce package
   - Uploader tous les fichiers vers /home/cp2639565p41/aime/
   - Le fichier passenger_wsgi.py doit être dans le dossier racine de l'app

2. CONFIGURATION PYTHON:
   - Aller dans cPanel > Python App
   - Créer une nouvelle application Python 3.9
   - Définir le répertoire d'application: /home/cp2639565p41/aime
   - Définir le point d'entrée: passenger_wsgi.py

3. INSTALLATION DES DÉPENDANCES:
   - Activer l'environnement virtuel dans cPanel
   - Installer via requirements.txt
   - Ou utiliser le terminal cPanel:
     pip install -r requirements.txt

4. CONFIGURATION BASE DE DONNÉES:
   - Vérifier que la BDD MySQL existe: cp2639565p41_aimer2639565
   - Utilisateur: cp2639565p41_aimer2639565
   - Les paramètres sont dans aimesite/production_settings.py

5. MIGRATIONS DJANGO:
   Dans le terminal cPanel ou Python App:
   python manage.py collectstatic --noinput
   python manage.py migrate
   python manage.py createsuperuser (optionnel)

6. FICHIERS STATIQUES:
   - Les fichiers statiques seront copiés vers public_html/staticfiles/
   - Configuration WhiteNoise activée

7. DOMAINE:
   - Pointer aime-rdc.org vers le dossier de l'application
   - Vérifier les DNS

🔧 CONFIGURATION DÉJÀ FAITE:
✅ passenger_wsgi.py configuré pour cp2639565p41
✅ production_settings.py avec MySQL
✅ WhiteNoise pour fichiers statiques
✅ .htaccess pour redirections et sécurité
✅ Configuration SSL/HTTPS

🧪 TESTS:
- Accéder à https://aime-rdc.org
- Vérifier que les fichiers statiques se chargent
- Tester l'administration Django: /admin/

⚠️  IMPORTANT:
- Backup toujours avant déploiement
- Vérifier les logs d'erreur dans cPanel
- Le fichier wsgi_error.log sera créé en cas d'erreur

📞 SUPPORT:
En cas de problème, vérifier:
1. Les logs Python dans cPanel
2. Le fichier wsgi_error.log
3. Les permissions des fichiers
4. La configuration de la base de données
"""
    
    with open(deploy_dir / "INSTRUCTIONS_DEPLOYMENT.txt", "w", encoding="utf-8") as f:
        f.write(instructions)
    print("✅ Créé: INSTRUCTIONS_DEPLOYMENT.txt")

def create_zip_archive(deploy_dir):
    """Crée une archive ZIP du package"""
    zip_path = "deployment_package.zip"
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(deploy_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arc_name = os.path.relpath(file_path, deploy_dir)
                zipf.write(file_path, arc_name)
    
    print(f"✅ Archive créée: {zip_path}")

if __name__ == "__main__":
    create_deployment_package()
    print("\n🔥 Déploiement prêt ! Suivez les instructions dans INSTRUCTIONS_DEPLOYMENT.txt")