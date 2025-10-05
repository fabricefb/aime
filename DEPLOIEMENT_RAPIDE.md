# 🚀 GUIDE RAPIDE - DÉPLOIEMENT DES CORRECTIONS

## ✅ OPTION 1 : Déploiement depuis votre machine locale (RECOMMANDÉ)

### Prérequis :
- Avoir configuré SSH pour se connecter à votre serveur
- Le script `deploy-fixes.sh` est dans votre dépôt local

### Commandes :

```bash
# 1. Rendre le script exécutable
chmod +x deploy-fixes.sh

# 2. Exécuter le déploiement
./deploy-fixes.sh
```

Le script va :
1. ✅ Pull les modifications depuis GitHub sur le serveur
2. ✅ Copier les fichiers vers `/public_html`
3. ✅ Installer les dépendances Python
4. ✅ Appliquer les migrations
5. ✅ Collecter les fichiers statiques
6. ✅ Corriger les permissions
7. ✅ Redémarrer l'application

**Durée : 2-3 minutes**

---

## ✅ OPTION 2 : Déploiement direct sur le serveur

### Étape 1 : Se connecter en SSH

```bash
ssh cp2639565p41@aime-rdc.org
```

### Étape 2 : Télécharger le script de déploiement

```bash
cd /home/cp2639565p41
wget https://raw.githubusercontent.com/fabricefb/aime/main/deploy-on-server.sh
chmod +x deploy-on-server.sh
```

### Étape 3 : Exécuter le déploiement

```bash
bash deploy-on-server.sh
```

---

## ✅ OPTION 3 : Déploiement manuel (étape par étape)

Si vous préférez le faire manuellement :

```bash
# 1. Connexion SSH
ssh cp2639565p41@aime-rdc.org

# 2. Pull depuis GitHub
cd /home/cp2639565p41/repositories/aime
git pull origin main

# 3. Copier vers public_html
cp -R /home/cp2639565p41/repositories/aime/* /home/cp2639565p41/public_html/
cp /home/cp2639565p41/repositories/aime/.htaccess /home/cp2639565p41/public_html/

# 4. Activer l'environnement virtuel
source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate

# 5. Aller dans public_html
cd /home/cp2639565p41/public_html

# 6. Installer les dépendances
pip install -r requirements.txt

# 7. Appliquer les migrations
python manage.py migrate --noinput

# 8. Collecter les fichiers statiques
python manage.py collectstatic --noinput --clear

# 9. Corriger les permissions
chmod -R 755 /home/cp2639565p41/public_html

# 10. Redémarrer l'application
touch /home/cp2639565p41/public_html/tmp/restart.txt
```

---

## 📋 VÉRIFICATION POST-DÉPLOIEMENT

### 1. Vérifier que le site fonctionne

```bash
curl -I https://aime-rdc.org
```

**Résultat attendu :**
```
HTTP/2 200
```

**Si vous voyez 500 :** Consultez les logs (voir ci-dessous)

### 2. Vérifier dans le navigateur

Ouvrir : **https://aime-rdc.org**

✅ La page d'accueil doit s'afficher  
✅ Les images et CSS doivent charger  
✅ Aucune erreur 500  

### 3. Tester l'administration

Ouvrir : **https://aime-rdc.org/admin**

✅ La page de connexion doit s'afficher  
✅ Connexion avec votre compte admin doit fonctionner  

---

## 🐛 EN CAS DE PROBLÈME

### Consulter les logs d'erreur

```bash
# Log Apache
ssh cp2639565p41@aime-rdc.org "tail -n 50 ~/logs/error_log"

# Log WSGI (créé automatiquement si erreur)
ssh cp2639565p41@aime-rdc.org "cat ~/public_html/wsgi_error.log"
```

### Vérifier les chemins dans passenger_wsgi.py

```bash
ssh cp2639565p41@aime-rdc.org "cat ~/public_html/passenger_wsgi.py | grep PROJECT_DIR"
```

**Résultat attendu :**
```
PROJECT_DIR = f'/home/cp2639565p41/public_html'
```

### Vérifier que Django fonctionne

```bash
ssh cp2639565p41@aime-rdc.org
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
