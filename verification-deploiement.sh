#!/bin/bash
# Script de vérification rapide du déploiement AIME RDC
# À exécuter sur le serveur cPanel après déploiement

echo "🔍 VÉRIFICATION RAPIDE DU DÉPLOIEMENT AIME RDC"
echo "=============================================="

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check() {
    echo -e "${BLUE}[$1]${NC} $2"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# 1. Vérifier la structure des fichiers
echo ""
check "1" "Vérification de la structure des fichiers..."
if [ -d "~/public_html/aime-rdc.org" ]; then
    success "Dossier projet trouvé"
    ls -la ~/public_html/aime-rdc.org/ | head -10
else
    error "Dossier projet manquant"
fi

# 2. Vérifier l'environnement virtuel
echo ""
check "2" "Vérification de l'environnement virtuel..."
if [ -d "~/virtualenv/aime-rdc.org" ]; then
    success "Environnement virtuel trouvé"
    source ~/virtualenv/aime-rdc.org/bin/activate
    python --version
else
    error "Environnement virtuel manquant"
fi

# 3. Vérifier les dépendances Python
echo ""
check "3" "Vérification des dépendances Python..."
if command -v pip &> /dev/null; then
    DEPENDENCIES=$(pip list | grep -E "(Django|Pillow|pymysql)")
    if [ -n "$DEPENDENCIES" ]; then
        success "Dépendances installées :"
        echo "$DEPENDENCIES"
    else
        error "Dépendances manquantes"
    fi
else
    error "pip non trouvé"
fi

# 4. Vérifier Django
echo ""
check "4" "Vérification de Django..."
cd ~/public_html/aime-rdc.org
if [ -f "manage.py" ]; then
    success "Fichier manage.py trouvé"
    python manage.py check --settings=aimesite.production_settings
    if [ $? -eq 0 ]; then
        success "Configuration Django OK"
    else
        error "Problème de configuration Django"
    fi
else
    error "Fichier manage.py manquant"
fi

# 5. Vérifier les fichiers statiques
echo ""
check "5" "Vérification des fichiers statiques..."
if [ -d "staticfiles" ]; then
    STATIC_COUNT=$(find staticfiles -type f | wc -l)
    success "Fichiers statiques : $STATIC_COUNT fichiers"
else
    warning "Dossier staticfiles manquant"
fi

# 6. Vérifier les permissions
echo ""
check "6" "Vérification des permissions..."
PERMS=$(stat -c "%a" ~/public_html/aime-rdc.org/passenger_wsgi.py 2>/dev/null)
if [ "$PERMS" = "755" ] || [ "$PERMS" = "644" ]; then
    success "Permissions passenger_wsgi.py : $PERMS"
else
    warning "Permissions passenger_wsgi.py : $PERMS (devrait être 755)"
fi

# 7. Vérifier la base de données
echo ""
check "7" "Vérification de la base de données..."
python manage.py showmigrations --settings=aimesite.production_settings | tail -5

# 8. Test de l'application
echo ""
check "8" "Test de l'application..."
timeout 10 python manage.py runserver 0.0.0.0:8000 --settings=aimesite.production_settings &
SERVER_PID=$!
sleep 3
if kill -0 $SERVER_PID 2>/dev/null; then
    success "Serveur de test démarré"
    kill $SERVER_PID
else
    warning "Serveur de test n'a pas démarré"
fi

# Résumé
echo ""
echo "📊 RÉSUMÉ DE LA VÉRIFICATION"
echo "============================"
echo ""
echo "🌐 URL de production : https://aime-rdc.org"
echo "👤 Administration : https://aime-rdc.orgm/admin/"
echo ""
echo "🔧 Commandes utiles :"
echo "  Redémarrer l'app : touch ~/public_html/aime-rdc.org/passenger_wsgi.py"
echo "  Voir les logs : tail -f ~/logs/error_log"
echo "  Créer admin : python manage.py createsuperuser --settings=aimesite.production_settings"
echo ""
success "Vérification terminée !"
