#!/bin/bash

# Configuration
CPANEL_USER="cp2639565p41"
SITE_PATH="/home/cp2639565p41/aime-rdc.org"
REPO_URL="https://github.com/fabricefb/aime.git"
BRANCH="main"

echo "🚀 Début du déploiement vers cPanel..."

# Se connecter via SSH et exécuter les commandes de déploiement
ssh $CPANEL_USER@aime-rdc.org << 'ENDSSH'
    # Aller dans le répertoire du site
    cd /home/cp2639565p41/aime-rdc.org

    # Sauvegarder les fichiers importants
    echo "📦 Sauvegarde des fichiers de configuration..."
    if [ -f .env ]; then
        cp .env .env.backup
    fi

    # Mettre à jour depuis GitHub
    echo "⬇️ Récupération des changements depuis GitHub..."
    if [ -d .git ]; then
        git fetch origin main
        git reset --hard origin/main
    else
        git clone -b main https://github.com/fabricefb/aime.git .
    fi

    # Restaurer les fichiers de configuration
    if [ -f .env.backup ]; then
        mv .env.backup .env
    fi

    # Activer l'environnement virtuel
    echo "🐍 Activation de l'environnement Python..."
    source /home/cp2639565p41/virtualenv/aime-rdc.org/3.9/bin/activate

    # Installer les dépendances
    echo "📦 Installation des dépendances..."
    pip install -r requirements.txt

    # Collecter les fichiers statiques
    echo "📁 Collection des fichiers statiques..."
    python manage.py collectstatic --noinput

    # Appliquer les migrations
    echo "🗄️ Application des migrations..."
    python manage.py migrate --noinput

    # Corriger les permissions
    echo "🔒 Correction des permissions..."
    chmod 755 manage.py restart-site.sh
    chmod -R 755 staticfiles
    chmod -R 755 main/static

    # Redémarrer l'application
    echo "🔄 Redémarrage de l'application..."
    mkdir -p tmp
    touch tmp/restart.txt

    # Désactiver l'environnement virtuel
    deactivate

    echo "✅ Déploiement terminé avec succès !"
ENDSSH