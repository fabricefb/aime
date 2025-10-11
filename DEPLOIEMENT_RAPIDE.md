# ⚡ Déploiement Rapide - AIME RDC# 🚀 GUIDE RAPIDE - DÉPLOIEMENT DES CORRECTIONS



## 🚀 Commande Ultra-Rapide## ✅ OPTION 1 : Déploiement depuis votre machine locale (RECOMMANDÉ)



**Pour déployer ou mettre à jour :**### Prérequis :

- Avoir configuré SSH pour se connecter à votre serveur

```bash- Le script `deploy-fixes.sh` est dans votre dépôt local

ssh cp2639565p41@aime-rdc.org 'cd /home/cp2639565p41/repositories/aime && git pull origin main && ./deploy-auto.sh'

```### Commandes :



---```bash

# 1. Rendre le script exécutable

## 📋 Prérequis (Une seule fois)chmod +x deploy-fixes.sh



### 1. Créer l'Application Python dans cPanel# 2. Exécuter le déploiement

./deploy-fixes.sh

``````

Python version   : 3.9.19

Application root : aimeLe script va :

Application URL  : /1. ✅ Pull les modifications depuis GitHub sur le serveur

Startup file     : passenger_wsgi.py2. ✅ Copier les fichiers vers `/public_html`

Entry point      : application3. ✅ Installer les dépendances Python

```4. ✅ Appliquer les migrations

5. ✅ Collecter les fichiers statiques

### 2. Variables d'Environnement (cPanel)6. ✅ Corriger les permissions

7. ✅ Redémarrer l'application

```bash

DJANGO_SETTINGS_MODULE = aimesite.production_settings**Durée : 2-3 minutes**

DEBUG = False

ALLOWED_HOSTS = aime-rdc.org,www.aime-rdc.org---

DB_NAME = cp2639565p41_aimer2639565

DB_USER = cp2639565p41_aimer2639565## ✅ OPTION 2 : Déploiement direct sur le serveur

DB_PASSWORD = votre_mot_de_passe

SECRET_KEY = générer_avec_commande_ci-dessous### Étape 1 : Se connecter en SSH

```

```bash

**Générer SECRET_KEY :**ssh cp2639565p41@aime-rdc.org

```bash```

python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

```### Étape 2 : Télécharger le script de déploiement



### 3. Configuration SSH GitHub (Une seule fois)```bash

cd /home/cp2639565p41

```bashwget https://raw.githubusercontent.com/fabricefb/aime/main/deploy-on-server.sh

ssh cp2639565p41@aime-rdc.orgchmod +x deploy-on-server.sh

ssh-keygen -t ed25519 -C "cp2639565p41@aime-rdc.org" -N "" -f ~/.ssh/id_ed25519```

cat ~/.ssh/id_ed25519.pub  # Copier et ajouter sur GitHub

```### Étape 3 : Exécuter le déploiement



Ajoutez la clé sur : https://github.com/settings/keys```bash

bash deploy-on-server.sh

---```



## 🔧 Première Installation---



```bash## ✅ OPTION 3 : Déploiement manuel (étape par étape)

# 1. Se connecter

ssh cp2639565p41@aime-rdc.orgSi vous préférez le faire manuellement :



# 2. Cloner le dépôt```bash

cd /home/cp2639565p41/repositories# 1. Connexion SSH

git clone git@github.com:fabricefb/aime.gitssh cp2639565p41@aime-rdc.org



# 3. Lancer le déploiement# 2. Pull depuis GitHub

cd aimecd /home/cp2639565p41/repositories/aime

chmod +x deploy-auto.shgit pull origin main

./deploy-auto.sh

```# 3. Copier vers public_html

cp -R /home/cp2639565p41/repositories/aime/* /home/cp2639565p41/public_html/

---cp /home/cp2639565p41/repositories/aime/.htaccess /home/cp2639565p41/public_html/



## 🔄 Mises à Jour Ultérieures# 4. Activer l'environnement virtuel

source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate

```bash

# Méthode 1 : Depuis votre machine locale# 5. Aller dans public_html

ssh cp2639565p41@aime-rdc.org 'cd /home/cp2639565p41/repositories/aime && git pull && ./deploy-auto.sh'cd /home/cp2639565p41/public_html



# Méthode 2 : Connecté au serveur# 6. Installer les dépendances

cd /home/cp2639565p41/repositories/aimepip install -r requirements.txt

git pull origin main

./deploy-auto.sh# 7. Appliquer les migrations

```python manage.py migrate --noinput



---# 8. Collecter les fichiers statiques

python manage.py collectstatic --noinput --clear

## 📍 Chemins Importants

# 9. Corriger les permissions

```chmod -R 755 /home/cp2639565p41/public_html

Application       : /home/cp2639565p41/aime

Dépôt Git        : /home/cp2639565p41/repositories/aime# 10. Redémarrer l'application

Public HTML      : /home/cp2639565p41/public_htmltouch /home/cp2639565p41/public_html/tmp/restart.txt

Virtualenv       : /home/cp2639565p41/virtualenv/aime/3.9```

Logs             : /home/cp2639565p41/logs/error_log

WSGI Errors      : /home/cp2639565p41/aime/wsgi_error.log---

```

## 📋 VÉRIFICATION POST-DÉPLOIEMENT

---

### 1. Vérifier que le site fonctionne

## 🔍 Vérifications Rapides

```bash

```bashcurl -I https://aime-rdc.org

# Voir les logs d'erreur```

tail -n 50 ~/logs/error_log

**Résultat attendu :**

# Redémarrer manuellement```

cd ~/aime && touch tmp/restart.txtHTTP/2 200

```

# Vérifier les fichiers statiques

ls -la ~/public_html/staticfiles/admin/**Si vous voyez 500 :** Consultez les logs (voir ci-dessous)



# Tester la connexion MySQL### 2. Vérifier dans le navigateur

mysql -u cp2639565p41_aimer2639565 -p cp2639565p41_aimer2639565

```Ouvrir : **https://aime-rdc.org**



---✅ La page d'accueil doit s'afficher  

✅ Les images et CSS doivent charger  

## ✅ Après Déploiement✅ Aucune erreur 500  



1. ⏰ **Attendre 10-15 secondes**### 3. Tester l'administration

2. 🌐 **Tester** : https://aime-rdc.org

3. 🔐 **Admin** : https://aime-rdc.org/admin/Ouvrir : **https://aime-rdc.org/admin**



---✅ La page de connexion doit s'afficher  

✅ Connexion avec votre compte admin doit fonctionner  

## 🆘 Problèmes Courants

---

### Erreur 500

```bash## 🐛 EN CAS DE PROBLÈME

tail -n 100 ~/logs/error_log

cat ~/aime/wsgi_error.log### Consulter les logs d'erreur

```

```bash

### Erreur DisallowedHost# Log Apache

Vérifiez `ALLOWED_HOSTS` dans les variables d'environnement cPanel.ssh cp2639565p41@aime-rdc.org "tail -n 50 ~/logs/error_log"



### CSS/JS ne se chargent pas# Log WSGI (créé automatiquement si erreur)

```bashssh cp2639565p41@aime-rdc.org "cat ~/public_html/wsgi_error.log"

cd ~/aime```

source ~/virtualenv/aime/3.9/bin/activate

python manage.py collectstatic --noinput --clear### Vérifier les chemins dans passenger_wsgi.py

touch tmp/restart.txt

``````bash

ssh cp2639565p41@aime-rdc.org "cat ~/public_html/passenger_wsgi.py | grep PROJECT_DIR"

---```



## 📚 Documentation Complète**Résultat attendu :**

```

Voir : [GUIDE_DEPLOIEMENT_COMPLET.md](GUIDE_DEPLOIEMENT_COMPLET.md)PROJECT_DIR = f'/home/cp2639565p41/public_html'

```

---

### Vérifier que Django fonctionne

**Site** : https://aime-rdc.org  

**Admin** : https://aime-rdc.org/admin/  ```bash

**Dernière mise à jour** : 11 Octobre 2025ssh cp2639565p41@aime-rdc.org

cd /home/cp2639565p41/public_html
source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate
python manage.py check
```

**Résultat attendu :**
```
System check identified no issues (0 silenced).
```

### Redémarrer manuellement

```bash
ssh cp2639565p41@aime-rdc.org "touch ~/public_html/tmp/restart.txt"
```

Attendre 10-15 secondes puis rafraîchir le site.

---

## 📊 CHECKLIST COMPLÈTE

Après le déploiement, vérifier :

- [ ] `git pull` a réussi dans `/repositories/aime`
- [ ] Fichiers copiés dans `/public_html`
- [ ] `passenger_wsgi.py` contient `/public_html` (pas `/aime-rdc.org`)
- [ ] `.htaccess` contient `/virtualenv/public_html/3.9/bin/python`
- [ ] Migrations appliquées sans erreur
- [ ] Fichiers statiques collectés dans `/public_html/staticfiles/`
- [ ] Permissions `755` sur `/public_html`
- [ ] `tmp/restart.txt` touché
- [ ] Site accessible : https://aime-rdc.org
- [ ] Pas d'erreur 500
- [ ] CSS et images chargent
- [ ] Admin accessible : https://aime-rdc.org/admin

---

## 🎯 COMMANDES UTILES

### Déploiement complet en une ligne

```bash
ssh cp2639565p41@aime-rdc.org "cd /home/cp2639565p41/repositories/aime && git pull origin main && cd /home/cp2639565p41/public_html && bash post-deploy.sh"
```

### Voir les logs en temps réel

```bash
ssh cp2639565p41@aime-rdc.org "tail -f ~/logs/error_log"
# Ctrl+C pour arrêter
```

### Redémarrage rapide

```bash
ssh cp2639565p41@aime-rdc.org "touch ~/public_html/tmp/restart.txt"
```

### Vérifier l'état du site

```bash
ssh cp2639565p41@aime-rdc.org "cd ~/public_html && source ~/virtualenv/public_html/3.9/bin/activate && python manage.py check && curl -I https://aime-rdc.org"
```

---

## 🆘 ROLLBACK D'URGENCE

Si le site ne fonctionne plus :

```bash
ssh cp2639565p41@aime-rdc.org
cd /home/cp2639565p41/repositories/aime

# Voir l'historique
git log --oneline -10

# Revenir au commit précédent (remplacer <hash> par le bon commit)
git checkout <hash-du-commit-qui-marchait>

# Recopier vers public_html
cp -R * /home/cp2639565p41/public_html/

# Redémarrer
touch /home/cp2639565p41/public_html/tmp/restart.txt
```

---

## ✅ RÉSULTAT ATTENDU

Après le déploiement, vous devriez voir :

```
✅ DÉPLOIEMENT TERMINÉ !
🌐 Site : https://aime-rdc.org
```

Et en ouvrant le site dans votre navigateur :
- ✅ Page d'accueil s'affiche
- ✅ Pas d'erreur 500
- ✅ Tous les fichiers statiques chargent

---

**🚀 Choisissez l'option qui vous convient le mieux et lancez le déploiement !**

*Si vous rencontrez un problème, consultez `DEPLOIEMENT_CPANEL_GUIDE.md` pour plus de détails.*
