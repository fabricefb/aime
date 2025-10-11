#!/bin/bash
################################################################################
# Script de déploiement automatique pour AIME - aime-rdc.org
# Version: 2.0
# Date: 11 Octobre 2025
# 
# Ce script déploie automatiquement l'application Django sur cPanel
################################################################################

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CPANEL_USER="cp2639565p41"
APP_DIR="/home/${CPANEL_USER}/aime"
REPO_DIR="/home/${CPANEL_USER}/repositories/aime"
PUBLIC_HTML="/home/${CPANEL_USER}/public_html"
VENV_PATH="/home/${CPANEL_USER}/virtualenv/aime/3.9"
BACKUP_DIR="/home/${CPANEL_USER}/backups/$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║        🚀 DÉPLOIEMENT AUTOMATIQUE - AIME RDC 🚀               ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier que nous sommes sur le serveur
if [[ ! -d "/home/${CPANEL_USER}" ]]; then
    log_error "Ce script doit être exécuté sur le serveur cPanel"
    exit 1
fi

# 1. SAUVEGARDE
log_info "Étape 1/10 : Création de la sauvegarde..."
mkdir -p "${BACKUP_DIR}"

if [[ -f "${APP_DIR}/db.sqlite3" ]]; then
    cp "${APP_DIR}/db.sqlite3" "${BACKUP_DIR}/"
    log_success "Base de données SQLite sauvegardée"
fi

if [[ -d "${PUBLIC_HTML}/media" ]]; then
    cp -r "${PUBLIC_HTML}/media" "${BACKUP_DIR}/"
    log_success "Fichiers média sauvegardés"
fi

# 2. MISE À JOUR DU CODE DEPUIS GITHUB
log_info "Étape 2/10 : Mise à jour depuis GitHub..."
cd "${REPO_DIR}"
git fetch origin
git reset --hard origin/main
log_success "Code mis à jour depuis GitHub"

# 3. COPIER LE CODE VERS LE DOSSIER DE L'APPLICATION
log_info "Étape 3/10 : Copie du code..."
rsync -av --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' \
    "${REPO_DIR}/" "${APP_DIR}/"
log_success "Code copié vers ${APP_DIR}"

# 4. ACTIVER L'ENVIRONNEMENT VIRTUEL
log_info "Étape 4/10 : Activation de l'environnement virtuel..."
source "${VENV_PATH}/bin/activate"
log_success "Environnement virtuel activé"

# 5. INSTALLER/METTRE À JOUR LES DÉPENDANCES
log_info "Étape 5/10 : Installation des dépendances Python..."
cd "${APP_DIR}"
pip install --upgrade pip -q
pip install -r requirements.txt -q
log_success "Dépendances installées"

# 6. CRÉER LES DOSSIERS NÉCESSAIRES
log_info "Étape 6/10 : Création des dossiers..."
mkdir -p "${PUBLIC_HTML}/staticfiles"
mkdir -p "${PUBLIC_HTML}/media"
mkdir -p "${APP_DIR}/logs"
mkdir -p "${APP_DIR}/cache"
mkdir -p "${APP_DIR}/tmp"
log_success "Dossiers créés"

# 7. COLLECTER LES FICHIERS STATIQUES
log_info "Étape 7/10 : Collection des fichiers statiques..."
cd "${APP_DIR}"
python manage.py collectstatic --noinput --clear
log_success "Fichiers statiques collectés"

# 8. APPLIQUER LES MIGRATIONS
log_info "Étape 8/10 : Application des migrations..."
python manage.py migrate --noinput
log_success "Migrations appliquées"

# 9. DÉFINIR LES PERMISSIONS
log_info "Étape 9/10 : Configuration des permissions..."
chmod -R 755 "${APP_DIR}"
chmod 644 "${APP_DIR}/passenger_wsgi.py"
chmod 644 "${PUBLIC_HTML}/.htaccess"
chmod -R 755 "${PUBLIC_HTML}/staticfiles"
chmod -R 755 "${PUBLIC_HTML}/media"
log_success "Permissions configurées"

# 10. REDÉMARRER L'APPLICATION
log_info "Étape 10/10 : Redémarrage de l'application..."
touch "${APP_DIR}/tmp/restart.txt"
log_success "Application redémarrée"

# VÉRIFICATIONS POST-DÉPLOIEMENT
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                 ✅ DÉPLOIEMENT RÉUSSI ! ✅${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
log_info "Vérifications :"
echo ""

# Vérifier les fichiers critiques
if [[ -f "${APP_DIR}/passenger_wsgi.py" ]]; then
    echo -e "  ${GREEN}✓${NC} passenger_wsgi.py présent"
else
    echo -e "  ${RED}✗${NC} passenger_wsgi.py MANQUANT"
fi

if [[ -f "${PUBLIC_HTML}/.htaccess" ]]; then
    echo -e "  ${GREEN}✓${NC} .htaccess présent"
else
    echo -e "  ${RED}✗${NC} .htaccess MANQUANT"
fi

if [[ -d "${PUBLIC_HTML}/staticfiles/admin" ]]; then
    echo -e "  ${GREEN}✓${NC} Fichiers statiques admin présents"
else
    echo -e "  ${YELLOW}⚠${NC}  Fichiers statiques admin potentiellement manquants"
fi

# Afficher les chemins configurés
echo ""
log_info "Configuration des chemins :"
echo "  App Dir     : ${APP_DIR}"
echo "  Public HTML : ${PUBLIC_HTML}"
echo "  Virtualenv  : ${VENV_PATH}"
echo "  Backup      : ${BACKUP_DIR}"
echo ""

# Instructions finales
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_info "Prochaines étapes :"
echo ""
echo "  1. ⏰ Attendez 10-15 secondes pour que Passenger redémarre"
echo "  2. 🌐 Testez le site : https://aime-rdc.org"
echo "  3. 🔍 Vérifiez les logs en cas d'erreur :"
echo "     tail -f ~/logs/error_log"
echo "     cat ${APP_DIR}/wsgi_error.log"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Désactiver le virtualenv
deactivate 2>/dev/null || true

exit 0
