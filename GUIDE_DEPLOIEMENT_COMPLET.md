# 🚀 Guide de Déploiement Complet - AIME RDC

**Date:** 11 Octobre 2025  
**Site:** https://aime-rdc.org  
**Version:** 2.0

---

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Configuration Initiale](#configuration-initiale)
3. [Déploiement Automatique](#déploiement-automatique)
4. [Déploiement Manuel](#déploiement-manuel)
5. [Variables d'Environnement](#variables-denvironnement)
6. [Résolution de Problèmes](#résolution-de-problèmes)

---

## 🔧 Prérequis

### Sur cPanel

- ✅ Application Python 3.9 créée
- ✅ Accès SSH activé
- ✅ Clé SSH configurée pour GitHub
- ✅ MySQL database créée

### Informations Serveur

```
Utilisateur cPanel : cp2639565p41
Serveur           : web45.lws-hosting.com
Domaine           : aime-rdc.org
Python Version    : 3.9.23
```

---

## ⚙️ Configuration Initiale

### 1. Créer l'Application Python dans cPanel

1. **Connectez-vous à cPanel**
2. **Allez dans "Setup Python App"**
3. **Créez une application avec ces paramètres :**

```
Python version        : 3.9.19
Application root      : aime
Application URL       : /
Application startup   : passenger_wsgi.py
Application entry     : application
```

4. **Notez le chemin du virtualenv** affiché (ex: `/home/cp2639565p41/virtualenv/aime/3.9`)

### 2. Configurer les Variables d'Environnement

Dans cPanel > Setup Python App > Votre application > Environment variables :

```bash
DJANGO_SETTINGS_MODULE = aimesite.production_settings
PYTHONPATH = /home/cp2639565p41/aime
DEBUG = False
ALLOWED_HOSTS = aime-rdc.org,www.aime-rdc.org

# Base de données
DB_NAME = cp2639565p41_aimer2639565
DB_USER = cp2639565p41_aimer2639565
DB_PASSWORD = votre_mot_de_passe_mysql
DB_HOST = localhost
DB_PORT = 3306

# Chemins
STATIC_ROOT = /home/cp2639565p41/public_html/staticfiles
MEDIA_ROOT = /home/cp2639565p41/public_html/media

# Email (optionnel)
EMAIL_HOST_USER = web@aime-rdc.org
EMAIL_HOST_PASSWORD = votre_mot_de_passe_email

# Admin
ADMIN_EMAIL = admin@aime-rdc.org
```

**Générer une SECRET_KEY sécurisée :**

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Ajoutez la clé générée :

```bash
SECRET_KEY = <votre_clé_générée>
```

### 3. Configurer SSH pour GitHub

```bash
# Se connecter au serveur
ssh cp2639565p41@aime-rdc.org

# Générer une clé SSH
ssh-keygen -t ed25519 -C "cp2639565p41@aime-rdc.org" -f ~/.ssh/id_ed25519 -N ""

# Afficher la clé publique
cat ~/.ssh/id_ed25519.pub
```

**Ajoutez cette clé sur GitHub :**
1. Allez sur https://github.com/settings/keys
2. Cliquez "New SSH key"
3. Collez la clé publique
4. Titre : `cPanel AIME Production`

**Testez la connexion :**

```bash
ssh -T git@github.com
# Résultat attendu : "Hi fabricefb! You've successfully authenticated..."
```

---

## 🚀 Déploiement Automatique

### Première Installation

```bash
# 1. Se connecter au serveur
ssh cp2639565p41@aime-rdc.org

# 2. Cloner le dépôt
cd /home/cp2639565p41/repositories
git clone git@github.com:fabricefb/aime.git

# 3. Rendre le script exécutable
cd /home/cp2639565p41/repositories/aime
chmod +x deploy-auto.sh

# 4. Lancer le déploiement
./deploy-auto.sh
```

### Mises à Jour Ultérieures

```bash
# Connectez-vous
ssh cp2639565p41@aime-rdc.org

# Lancez le script
cd /home/cp2639565p41/repositories/aime
git pull origin main
./deploy-auto.sh
```

**Le script automatique fait tout :**
- ✅ Sauvegarde de la base de données et des médias
- ✅ Mise à jour du code depuis GitHub
- ✅ Installation des dépendances
- ✅ Collection des fichiers statiques
- ✅ Application des migrations
- ✅ Configuration des permissions
- ✅ Redémarrage de l'application

---

## 🔨 Déploiement Manuel

Si vous préférez contrôler chaque étape :

### Étape 1 : Mise à jour du Code

```bash
cd /home/cp2639565p41/repositories/aime
git pull origin main

rsync -av --exclude='.git' --exclude='__pycache__' \
    /home/cp2639565p41/repositories/aime/ \
    /home/cp2639565p41/aime/
```

### Étape 2 : Activer l'Environnement Virtuel

```bash
source /home/cp2639565p41/virtualenv/aime/3.9/bin/activate
cd /home/cp2639565p41/aime
```

### Étape 3 : Installer les Dépendances

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Étape 4 : Créer les Dossiers

```bash
mkdir -p /home/cp2639565p41/public_html/staticfiles
mkdir -p /home/cp2639565p41/public_html/media
mkdir -p /home/cp2639565p41/aime/logs
mkdir -p /home/cp2639565p41/aime/cache
```

### Étape 5 : Collecter les Fichiers Statiques

```bash
python manage.py collectstatic --noinput --clear
```

### Étape 6 : Appliquer les Migrations

```bash
python manage.py migrate
```

### Étape 7 : Configurer les Permissions

```bash
chmod -R 755 /home/cp2639565p41/aime
chmod 644 /home/cp2639565p41/aime/passenger_wsgi.py
chmod 644 /home/cp2639565p41/public_html/.htaccess
```

### Étape 8 : Redémarrer

```bash
cd /home/cp2639565p41/aime
mkdir -p tmp
touch tmp/restart.txt
```

**Attendez 10-15 secondes puis testez :** https://aime-rdc.org

---

## 🔑 Variables d'Environnement

### Variables Essentielles

| Variable | Description | Exemple |
|----------|-------------|---------|
| `DJANGO_SETTINGS_MODULE` | Module de configuration Django | `aimesite.production_settings` |
| `SECRET_KEY` | Clé secrète Django | `django-insecure-xyz123...` |
| `DEBUG` | Mode debug (False en prod) | `False` |
| `ALLOWED_HOSTS` | Domaines autorisés | `aime-rdc.org,www.aime-rdc.org` |

### Variables de Base de Données

| Variable | Description | Exemple |
|----------|-------------|---------|
| `DB_NAME` | Nom de la base MySQL | `cp2639565p41_aimer2639565` |
| `DB_USER` | Utilisateur MySQL | `cp2639565p41_aimer2639565` |
| `DB_PASSWORD` | Mot de passe MySQL | `VotreMotDePasse` |
| `DB_HOST` | Hôte MySQL | `localhost` |
| `DB_PORT` | Port MySQL | `3306` |

### Variables de Chemins

| Variable | Description | Exemple |
|----------|-------------|---------|
| `STATIC_ROOT` | Dossier fichiers statiques | `/home/cp2639565p41/public_html/staticfiles` |
| `MEDIA_ROOT` | Dossier fichiers média | `/home/cp2639565p41/public_html/media` |
| `PYTHONPATH` | Chemin Python | `/home/cp2639565p41/aime` |

---

## 🔍 Résolution de Problèmes

### Erreur 500 : Internal Server Error

**Symptôme :** Page blanche avec "Internal Server Error"

**Solutions :**

```bash
# 1. Vérifier les logs
tail -n 100 ~/logs/error_log
cat ~/aime/wsgi_error.log

# 2. Vérifier les permissions
chmod 644 ~/aime/passenger_wsgi.py
chmod 644 ~/public_html/.htaccess

# 3. Vérifier que PyMySQL est installé
source ~/virtualenv/aime/3.9/bin/activate
pip list | grep -i pymysql

# 4. Redémarrer
cd ~/aime
touch tmp/restart.txt
```

### Erreur 403 : Forbidden

**Symptôme :** "You don't have permission to access this resource"

**Solutions :**

```bash
# 1. Vérifier .htaccess
cat ~/public_html/.htaccess | grep PassengerPython
# Doit afficher : PassengerPython /home/cp2639565p41/virtualenv/aime/3.9/bin/python

# 2. Vérifier les permissions
chmod 755 ~/aime
chmod 644 ~/aime/passenger_wsgi.py

# 3. Vérifier que passenger_wsgi.py est autorisé
grep "passenger_wsgi.py" ~/public_html/.htaccess
```

### DisallowedHost Error

**Symptôme :** "Invalid HTTP_HOST header: 'aime-rdc.org'"

**Solution :**

```bash
# Vérifier ALLOWED_HOSTS dans production_settings.py
cd ~/aime
grep -A 5 "ALLOWED_HOSTS" aimesite/production_settings.py

# Doit contenir :
# ALLOWED_HOSTS = [
#     'aime-rdc.org',
#     'www.aime-rdc.org',
# ]
```

### Fichiers Statiques Manquants (CSS/JS ne se chargent pas)

**Solution :**

```bash
# Re-collecter les fichiers statiques
source ~/virtualenv/aime/3.9/bin/activate
cd ~/aime
python manage.py collectstatic --noinput --clear

# Vérifier les permissions
chmod -R 755 ~/public_html/staticfiles

# Redémarrer
touch tmp/restart.txt
```

### Erreur de Connexion MySQL

**Symptôme :** "Can't connect to MySQL server"

**Solutions :**

```bash
# 1. Vérifier les identifiants
mysql -u cp2639565p41_aimer2639565 -p -h localhost

# 2. Vérifier les variables d'environnement dans cPanel
# DB_NAME, DB_USER, DB_PASSWORD doivent être corrects

# 3. Vérifier que PyMySQL est installé
pip list | grep -i pymysql
```

---

## 📊 Commandes Utiles

### Vérifier l'État de l'Application

```bash
# Voir les processus Python
ps aux | grep python

# Vérifier les logs en temps réel
tail -f ~/logs/error_log

# Vérifier l'espace disque
df -h
du -sh ~/aime/*
```

### Maintenance de la Base de Données

```bash
# Créer un superutilisateur
source ~/virtualenv/aime/3.9/bin/activate
cd ~/aime
python manage.py createsuperuser

# Voir les migrations
python manage.py showmigrations

# Créer des données de test
python manage.py create_sample_data
```

### Sauvegarde Manuelle

```bash
# Créer un dossier de sauvegarde
mkdir -p ~/backups/$(date +%Y%m%d)

# Sauvegarder la base MySQL
mysqldump -u cp2639565p41_aimer2639565 -p cp2639565p41_aimer2639565 \
    > ~/backups/$(date +%Y%m%d)/database.sql

# Sauvegarder les médias
cp -r ~/public_html/media ~/backups/$(date +%Y%m%d)/
```

---

## 📝 Checklist de Déploiement

Avant chaque déploiement, vérifiez :

- [ ] Code committé et poussé sur GitHub
- [ ] Variables d'environnement configurées dans cPanel
- [ ] Sauvegarde de la base de données effectuée
- [ ] Tests locaux réussis (`python manage.py test`)
- [ ] Fichier `requirements.txt` à jour
- [ ] Migrations créées (`python manage.py makemigrations`)

Après le déploiement :

- [ ] Site accessible (https://aime-rdc.org)
- [ ] Admin accessible (https://aime-rdc.org/admin/)
- [ ] Fichiers statiques se chargent correctement
- [ ] Pas d'erreurs dans les logs
- [ ] Formulaires fonctionnels
- [ ] Upload de fichiers fonctionne

---

## 🆘 Support

En cas de problème persistant :

1. **Logs** : Consultez `~/logs/error_log` et `~/aime/wsgi_error.log`
2. **Mode Debug** : Temporairement activer `DEBUG=True` pour voir les erreurs détaillées
3. **Restauration** : Utilisez les sauvegardes dans `~/backups/`

---

**Dernière mise à jour :** 11 Octobre 2025  
**Auteur :** AIME RDC DevOps Team
