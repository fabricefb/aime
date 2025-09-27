#!/bin/bash

# Configuration
CPANEL_USER="cp2639565p41"
SITE_PATH="/home/cp2639565p41/aime-rdc.org"
HOST="aime-rdc.org"

echo "🚀 Début du déploiement via SFTP..."

# Créer un répertoire temporaire pour les fichiers
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# Cloner le dépôt
git clone --depth 1 https://github.com/fabricefb/aime.git .

# Supprimer les fichiers git
rm -rf .git

# Transférer les fichiers via SFTP
echo "📤 Transfert des fichiers via SFTP..."
sftp $CPANEL_USER@$HOST << 'ENDSFTP'
    cd $SITE_PATH
    put -r *
ENDSFTP

# Exécuter le script de redémarrage sur le serveur
echo "🔄 Redémarrage du site..."
ssh $CPANEL_USER@$HOST "cd $SITE_PATH && ./restart-site.sh"

# Nettoyer
rm -rf $TMP_DIR

echo "✅ Déploiement terminé avec succès !"