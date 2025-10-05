#!/bin/bash

# Configuration Git
git config --global user.name "AIME Deploy"
git config --global user.email "web@aime-rdc.org"

# Configuration du dépôt
mkdir -p ~/repositories/aime
cd ~/repositories/aime

# Initialisation du dépôt bare
git init --bare

# Création du hook post-receive
cat > hooks/post-receive << 'EOF'
#!/bin/bash

# Configuration
SITE_PATH="/home/cp2639565p41/public_html"
GIT_WORK_TREE=$SITE_PATH
PYTHON_ENV="/home/cp2639565p41/virtualenv/public_html/3.9/bin/activate"

# Checkout des fichiers
git --work-tree=$SITE_PATH --git-dir=/home/cp2639565p41/repositories/aime checkout -f main

# Activation de l'environnement Python
source $PYTHON_ENV

# Aller dans le répertoire du site
cd $SITE_PATH

# Installation des dépendances
pip install -r requirements.txt

# Collecte des fichiers statiques
python manage.py collectstatic --noinput

# Application des migrations
python manage.py migrate --noinput

# Correction des permissions
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod +x manage.py
chmod +x *.sh
chmod -R 755 staticfiles/

# Redémarrage de l'application
mkdir -p tmp
touch tmp/restart.txt

# Désactivation de l'environnement virtuel
deactivate
EOF

# Rendre le hook exécutable
chmod +x hooks/post-receive

echo "✅ Configuration du dépôt Git terminée !"
echo "Pour configurer votre dépôt local, exécutez :"
echo "git remote add cpanel ssh://cp2639565p41@aime-rdc.org/home/cp2639565p41/repositories/aime"