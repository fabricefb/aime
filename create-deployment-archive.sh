#!/bin/bash
# Script pour créer une archive de déploiement allégée - AIME RDC

echo "🚀 Création d'une archive de déploiement allégée..."

# Supprimer les anciennes archives
rm -f *.zip

# Créer l'archive allégée sans les gros fichiers
echo "📦 Création de l'archive principale (sans images lourdes)..."
zip -r aime-rdc-deployment-light.zip . \
    -x "*.git*" \
    -x "*__pycache__*" \
    -x "*.pyc" \
    -x "*.sqlite3" \
    -x "*.log" \
    -x "deployment/*" \
    -x ".DS_Store" \
    -x "venv/*" \
    -x ".env" \
    -x "*.zip" \
    -x "staticfiles/main/images/hero/*.JPG" \
    -x "main/static/main/images/hero/*.JPG" \
    -x "staticfiles/main/images/hero/*image*.jpg" \
    -x "main/static/main/images/hero/*image*.jpg"

echo ""
echo "📁 Création d'une archive séparée pour les images..."
zip -r aime-rdc-images.zip \
    staticfiles/main/images/hero/ \
    main/static/main/images/hero/

echo ""
echo "📋 Création de l'archive des fichiers essentiels uniquement..."
zip -r aime-rdc-essentials.zip \
    .htaccess \
    passenger_wsgi.py \
    .env.production \
    requirements.txt \
    manage.py \
    DEPLOIEMENT_SIMPLE.md \
    GUIDE_DEPLOIEMENT_CPANEL.md \
    verification-deploiement.sh \
    aimesite/ \
    main/ \
    -x "main/static/main/images/hero/*.JPG" \
    -x "main/static/main/images/hero/*image*.jpg" \
    -x "*__pycache__*" \
    -x "*.pyc"

echo ""
echo "✅ Archives créées :"
echo "📦 aime-rdc-deployment-light.zip  - Projet complet (sans grosses images)"
echo "🖼️ aime-rdc-images.zip           - Images du projet"
echo "⚡ aime-rdc-essentials.zip       - Fichiers essentiels uniquement"
echo ""
echo "💡 Recommandation : Utilisez 'aime-rdc-essentials.zip' pour un déploiement rapide"

ls -lh *.zip