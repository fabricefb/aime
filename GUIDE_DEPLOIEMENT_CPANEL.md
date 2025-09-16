# 🚀 GUIDE COMPLET DE DÉPLOIEMENT AIME RDC SUR CPANEL

## 📋 Prérequis
- ✅ Compte cPanel actif
- ✅ Python 3.9+ activé dans cPanel
- ✅ MySQL/MariaDB disponible
- ✅ Archive `aime-rdc-cpanel-deployment.zip` téléchargée

---

## 📁 ÉTAPE 1 : Préparation des fichiers

### 1.1 Téléchargement de l'archive
```bash
# Téléchargez l'archive aime-rdc-cpanel-deployment.zip
# depuis votre ordinateur vers votre serveur cPanel
```

### 1.2 Extraction des fichiers
```bash
# Dans cPanel > Gestionnaire de fichiers :
# 1. Aller dans public_html/
# 2. Créer un dossier "aime-rdc.org"
# 3. Uploader et extraire l'archive dans ce dossier
```

---

## ⚙️ ÉTAPE 2 : Configuration cPanel

### 2.1 Créer un environnement virtuel Python
```bash
# Dans cPanel > Terminal :
python3 -m venv ~/virtualenv/aime-rdc.org
source ~/virtualenv/aime-rdc.org/bin/activate
```

### 2.2 Installer les dépendances
```bash
cd ~/public_html/aime-rdc.org
pip install -r requirements.txt
```

### 2.3 Créer la base de données MySQL
```sql
-- Dans cPanel > Bases de données MySQL :
-- Créer une nouvelle base de données : aime_rdc_db
-- Créer un utilisateur : aime_user
-- Donner tous les privilèges à l'utilisateur sur la base
```

---

## 🔧 ÉTAPE 3 : Configuration des fichiers

### 3.1 Modifier passenger_wsgi.py
```python
# Remplacer 'yourusername' par votre nom d'utilisateur cPanel
sys.path.insert(0, '/home/VOTRE_USERNAME/public_html/aime-rdc.org')
```

### 3.2 Modifier .htaccess
```apache
# Remplacer 'yourusername' par votre nom d'utilisateur cPanel
PassengerPython /home/VOTRE_USERNAME/virtualenv/aime-rdc.org/3.9/bin/python
```

### 3.3 Créer le fichier .env
```bash
# Créer le fichier .env dans le répertoire racine
nano ~/public_html/aime-rdc.org/.env
```

Contenu du fichier .env :
```env
DEBUG=False
SECRET_KEY=votre-cle-secrete-super-securisee-unique-et-longue
DATABASE_URL=mysql://aime_user:mot_de_passe@localhost/aime_rdc_db
ALLOWED_HOSTS=votre-domaine.com,www.votre-domaine.com
STATIC_URL=/static/
STATIC_ROOT=/home/VOTRE_USERNAME/public_html/aime-rdc.org/staticfiles
```

---

## 🗄️ ÉTAPE 4 : Configuration de la base de données

### 4.1 Appliquer les migrations Django
```bash
cd ~/public_html/aime-rdc.org
source ~/virtualenv/aime-rdc.org/bin/activate
python manage.py migrate --settings=aimesite.production_settings
```

### 4.2 Créer un superutilisateur
```bash
python manage.py createsuperuser --settings=aimesite.production_settings
```

---

## 📂 ÉTAPE 5 : Configuration des fichiers statiques

### 5.1 Collecter les fichiers statiques
```bash
python manage.py collectstatic --noinput --settings=aimesite.production_settings
```

### 5.2 Vérifier les permissions
```bash
# Permissions recommandées :
chmod -R 755 ~/public_html/aime-rdc.org/
chmod -R 644 ~/public_html/aime-rdc.org/staticfiles/
```

---

## 🌐 ÉTAPE 6 : Configuration du domaine

### 6.1 Dans cPanel > Domaines
- Ajouter votre domaine comme domaine principal ou addon
- Pointer vers le dossier `public_html/aime-rdc.org`

### 6.2 Configuration SSL (recommandé)
```bash
# Dans cPanel > SSL/TLS :
# Installer un certificat Let's Encrypt gratuit
```

---

## 🔧 ÉTAPE 7 : Dépannage

### 7.1 Erreur 500 - Internal Server Error
```bash
# Vérifier les logs :
tail -f ~/logs/error_log
tail -f ~/public_html/aime-rdc.org/django.log
```

### 7.2 Problème de fichiers statiques
```bash
# Vérifier les chemins dans aimesite/production_settings.py
# S'assurer que STATIC_ROOT pointe vers le bon dossier
```

### 7.3 Erreur de base de données
```bash
# Vérifier les identifiants dans .env
# Vérifier les permissions de la base de données
```

### 7.4 Redémarrer l'application
```bash
# Forcer le redémarrage via cPanel > Application Manager
# Ou toucher le fichier passenger_wsgi.py
touch ~/public_html/aime-rdc.org/passenger_wsgi.py
```

---

## ✅ ÉTAPE 8 : Tests finaux

### 8.1 Tester l'accès au site
- Visiter `https://votre-domaine.com`
- Vérifier que la page d'accueil se charge
- Tester la navigation

### 8.2 Tester l'administration
- Aller sur `https://votre-domaine.com/admin/`
- Se connecter avec le superutilisateur créé

### 8.3 Tester les fonctionnalités
- Formulaire de contact
- Système de chat
- Pages statiques

---

## 📞 Support et maintenance

### Mises à jour
```bash
# Pour mettre à jour le code :
cd ~/public_html/aime-rdc.org
git pull origin main
source ~/virtualenv/aime-rdc.org/bin/activate
pip install -r requirements.txt
python manage.py migrate --settings=aimesite.production_settings
python manage.py collectstatic --noinput --settings=aimesite.production_settings
```

### Sauvegardes
- Sauvegardez régulièrement votre base de données
- Sauvegardez vos fichiers médias
- Utilisez les outils de sauvegarde de cPanel

---

## 🎯 Checklist de déploiement

- [ ] Archive ZIP téléchargée et extraite
- [ ] Environnement virtuel Python créé
- [ ] Dépendances installées
- [ ] Base de données MySQL créée
- [ ] Fichiers de configuration modifiés
- [ ] Migrations Django appliquées
- [ ] Superutilisateur créé
- [ ] Fichiers statiques collectés
- [ ] Permissions configurées
- [ ] Domaine configuré
- [ ] SSL activé
- [ ] Tests effectués
- [ ] Site accessible

---

## 🚨 Points importants

1. **Sécurité** : Changez la SECRET_KEY par une clé unique et sécurisée
2. **Sauvegarde** : Sauvegardez régulièrement vos données
3. **Monitoring** : Surveillez les logs d'erreur régulièrement
4. **Performance** : Optimisez les images et activez la compression GZIP
5. **Mises à jour** : Gardez Django et les dépendances à jour

---

**🎉 Félicitations ! Votre site AIME RDC est maintenant déployé sur cPanel !**
