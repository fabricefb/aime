# 🚀 GUIDE DE DÉPLOIEMENT SIMPLE - AIME RDC

## 📋 Méthode Simple : Upload via cPanel

### ⚡ AVANT DE COMMENCER
- ✅ Archive prête : `aime-rdc-cpanel-deployment.zip` (151 MB)
- ✅ Guide complet : `GUIDE_DEPLOIEMENT_CPANEL.md`
- ✅ Configuration prête : `.htaccess`, `passenger_wsgi.py`

---

## 📦 ÉTAPE 1 : Préparation des fichiers

### 1.1 Télécharger l'archive
```bash
# Dans VS Code, faites un clic droit sur :
# aime-rdc-cpanel-deployment.zip
# Sélectionnez "Download"
```

### 1.2 Télécharger les fichiers de configuration
Téléchargez également :
- `.htaccess`
- `passenger_wsgi.py`
- `.env.production`
- `requirements.txt`

---

## 🌐 ÉTAPE 2 : Connexion à cPanel

### 2.1 Accéder à cPanel
- Allez sur : `https://votre-domaine.com/cpanel`
- Connectez-vous avec vos identifiants

### 2.2 Ouvrir le Gestionnaire de fichiers
- Dans cPanel : **"Gestionnaire de fichiers"**
- Sélectionner **"Accès aux fichiers Web"**
- Aller dans le dossier **`public_html/`**

---

## 📁 ÉTAPE 3 : Upload des fichiers

### 3.1 Créer le dossier du projet
1. Cliquer sur **"Nouveau dossier"**
2. Nommer : **`aime-rdc.org`**
3. Entrer dans le dossier

### 3.2 Uploader l'archive principale
1. Cliquer sur **"Uploader"**
2. Sélectionner **`aime-rdc-cpanel-deployment.zip`**
3. Attendre la fin de l'upload (151 MB)

### 3.3 Extraire l'archive
1. Clic droit sur **`aime-rdc-cpanel-deployment.zip`**
2. Sélectionner **"Extraire"**
3. Attendre l'extraction complète

### 3.4 Uploader les fichiers de configuration
Uploader dans le dossier `aime-rdc.org/` :
- `.htaccess`
- `passenger_wsgi.py`
- `.env.production`
- `requirements.txt`

---

## ⚙️ ÉTAPE 4 : Configuration cPanel

### 4.1 Créer l'environnement virtuel Python
```bash
# Dans cPanel > Terminal :
python3 -m venv ~/virtualenv/aime-rdc.org
source ~/virtualenv/aime-rdc.org/bin/activate
```

### 4.2 Installer les dépendances
```bash
cd ~/public_html/aime-rdc.org
pip install -r requirements.txt
```

### 4.3 Créer la base de données MySQL
1. Dans cPanel : **"Bases de données MySQL"**
2. Créer une base : **`aime_rdc_db`**
3. Créer un utilisateur : **`aime_user`**
4. Donner tous les privilèges

---

## 🔧 ÉTAPE 5 : Configuration des fichiers

### 5.1 Modifier passenger_wsgi.py
1. Ouvrir le fichier dans cPanel
2. Remplacer `yourusername` par votre nom d'utilisateur cPanel
```python
sys.path.insert(0, '/home/VOTRE_USERNAME/public_html/aime-rdc.org')
```

### 5.2 Modifier .htaccess
1. Ouvrir le fichier dans cPanel
2. Remplacer `yourusername` par votre nom d'utilisateur cPanel
```apache
PassengerPython /home/VOTRE_USERNAME/virtualenv/aime-rdc.org/3.9/bin/python
```

### 5.3 Modifier .env.production
1. Ouvrir le fichier dans cPanel
2. Remplacer par vos vraies informations :
```env
DATABASE_URL=mysql://aime_user:mot_de_passe@localhost/aime_rdc_db
ALLOWED_HOSTS=votre-domaine.com,www.votre-domaine.com
SECRET_KEY=votre-cle-secrete-unique
```

---

## 🗄️ ÉTAPE 6 : Configuration Django

### 6.1 Appliquer les migrations
```bash
cd ~/public_html/aime-rdc.org
source ~/virtualenv/aime-rdc.org/bin/activate
python manage.py migrate --settings=aimesite.production_settings
```

### 6.2 Créer un superutilisateur
```bash
python manage.py createsuperuser --settings=aimesite.production_settings
```

### 6.3 Collecter les fichiers statiques
```bash
python manage.py collectstatic --noinput --settings=aimesite.production_settings
```

---

## 🔒 ÉTAPE 7 : Permissions et sécurité

### 7.1 Corriger les permissions
```bash
chmod -R 755 ~/public_html/aime-rdc.org/
chmod -R 644 ~/public_html/aime-rdc.org/staticfiles/
```

### 7.2 Redémarrer l'application
```bash
touch ~/public_html/aime-rdc.org/passenger_wsgi.py
```

---

## 🌐 ÉTAPE 8 : Test final

### 8.1 Tester l'accès au site
- Visiter : `https://votre-domaine.com`
- Vérifier que la page d'accueil se charge

### 8.2 Tester l'administration
- Aller sur : `https://votre-domaine.com/admin/`
- Se connecter avec le superutilisateur créé

---

## 📋 Checklist de déploiement

- [ ] Archive ZIP téléchargée et extraite
- [ ] Environnement virtuel Python créé
- [ ] Dépendances installées
- [ ] Base de données MySQL créée
- [ ] Fichiers de configuration modifiés
- [ ] Migrations Django appliquées
- [ ] Superutilisateur créé
- [ ] Fichiers statiques collectés
- [ ] Permissions configurées
- [ ] Site accessible

---

## 🚨 Dépannage rapide

### Problème : Erreur 500
```bash
# Vérifier les logs
tail -f ~/logs/error_log
```

### Problème : Fichiers statiques ne se chargent pas
```bash
# Vérifier les permissions
chmod -R 755 ~/public_html/aime-rdc.org/staticfiles/
```

### Problème : Base de données
```bash
# Vérifier la configuration dans .env.production
# Redémarrer : touch ~/public_html/aime-rdc.org/passenger_wsgi.py
```

---

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez les logs d'erreur dans cPanel
2. Vérifiez les permissions des fichiers
3. Testez la configuration Python
4. Consultez le guide complet `GUIDE_DEPLOIEMENT_CPANEL.md`

---

**🎉 Félicitations ! Votre site AIME RDC est déployé !**

🌐 **URL de votre site :** `https://votre-domaine.com`
👤 **Administration :** `https://votre-domaine.com/admin/`