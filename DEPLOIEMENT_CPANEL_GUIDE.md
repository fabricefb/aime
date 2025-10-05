# 🚀 GUIDE DE DÉPLOIEMENT AIME RDC - cPanel

## ✅ CORRECTIONS APPORTÉES POUR ÉVITER LES ERREURS 500

### Fichiers Corrigés :

1. **`passenger_wsgi.py`** - Point d'entrée de l'application
   - ✅ Chemins corrigés pour `/home/cp2639565p41/public_html`
   - ✅ Gestion d'erreur améliorée avec logs
   - ✅ Import PyMySQL pour MySQL

2. **`.htaccess`** - Configuration Apache
   - ✅ PassengerPython pointe vers le bon virtualenv
   - ✅ Chemin : `/home/cp2639565p41/virtualenv/public_html/3.9/bin/python`

3. **`aimesite/production_settings.py`** - Settings Django production
   - ✅ Chemins statiques corrigés : `/home/cp2639565p41/public_html/staticfiles/`
   - ✅ Chemins média corrigés : `/home/cp2639565p41/public_html/media/`
   - ✅ Configuration MySQL maintenue

4. **`.cpanel.yml`** - Déploiement automatique
   - ✅ Simplifié pour éviter les erreurs
   - ✅ Copie des fichiers et restart automatique

---

## 📋 ÉTAPES APRÈS PUSH SUR GITHUB

### Depuis votre serveur cPanel (SSH) :

```bash
# 1. Se connecter en SSH
ssh cp2639565p41@aime-rdc.org

# 2. Aller dans le dépôt Git
cd /home/cp2639565p41/repositories/aime

# 3. Pull les dernières modifications
git pull origin main

# 4. Exécuter le script de post-déploiement
cd /home/cp2639565p41/public_html
bash post-deploy.sh
```

---

## 🔧 CONFIGURATION DE L'ENVIRONNEMENT VIRTUEL (À FAIRE UNE SEULE FOIS)

Si ce n'est pas déjà fait, créez l'environnement virtuel via cPanel :

1. **Accéder à "Setup Python App"** dans cPanel
2. **Créer une application** :
   - Python version: **3.9**
   - Application root: `/home/cp2639565p41/public_html`
   - Application URL: votre domaine principal
   - Application startup file: `passenger_wsgi.py`
   - Application Entry point: `application`

3. **Installer les dépendances** :
   ```bash
   source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate
   cd /home/cp2639565p41/public_html
   pip install -r requirements.txt
   ```

---

## 🗄️ CONFIGURATION DE LA BASE DE DONNÉES

### Paramètres actuels (déjà configurés) :

- **Database Name:** `cp2639565p41_aimer2639565`
- **Database User:** `cp2639565p41_aimer2639565`
- **Database Password:** `Wazenga007@bd`
- **Host:** `localhost`
- **Port:** `3306`

### Première fois :

```bash
cd /home/cp2639565p41/public_html
source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate
python manage.py migrate
python manage.py createsuperuser  # Créer un compte admin
```

---

## 📁 STRUCTURE DES DOSSIERS

```
/home/cp2639565p41/
├── public_html/                    # Application Django déployée
│   ├── passenger_wsgi.py          # Point d'entrée WSGI ✅
│   ├── .htaccess                  # Config Apache ✅
│   ├── manage.py
│   ├── requirements.txt
│   ├── aimesite/
│   │   ├── production_settings.py ✅
│   │   └── ...
│   ├── main/
│   ├── staticfiles/               # Fichiers statiques collectés
│   ├── media/                     # Fichiers médias uploadés
│   └── tmp/
│       └── restart.txt            # Touch pour redémarrer
│
├── repositories/
│   └── aime/                      # Dépôt Git
│
└── virtualenv/
    └── public_html/
        └── 3.9/                   # Environnement Python 3.9
            └── bin/
                └── python         # Interpréteur Python ✅
```

---

## 🔄 WORKFLOW DE DÉPLOIEMENT

### Option 1 : Déploiement via Git dans cPanel (Recommandé)

1. **Pusher sur GitHub** depuis votre machine locale :
   ```bash
   git add .
   git commit -m "Description des changements"
   git push origin main
   ```

2. **Dans cPanel > Git Version Control** :
   - Cliquez sur **"Pull or Deploy"**
   - Le `.cpanel.yml` s'exécutera automatiquement

3. **Redémarrer l'application** :
   ```bash
   touch /home/cp2639565p41/public_html/tmp/restart.txt
   ```

### Option 2 : Déploiement manuel via SSH

```bash
# 1. Connexion SSH
ssh cp2639565p41@aime-rdc.org

# 2. Pull depuis GitHub
cd /home/cp2639565p41/repositories/aime
git pull origin main

# 3. Copier vers public_html
cp -R * /home/cp2639565p41/public_html/

# 4. Post-déploiement
cd /home/cp2639565p41/public_html
bash post-deploy.sh
```

---

## 🐛 DÉPANNAGE DES ERREURS 500

### 1. Consulter les logs

```bash
# Log d'erreur Apache
tail -n 50 ~/logs/error_log

# Log d'erreur WSGI (créé automatiquement)
cat ~/public_html/wsgi_error.log
```

### 2. Vérifier les permissions

```bash
chmod -R 755 ~/public_html
chmod 644 ~/public_html/passenger_wsgi.py
```

### 3. Vérifier l'environnement virtuel

```bash
source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate
python --version  # Doit afficher Python 3.9.x
pip list | grep -i django  # Vérifier que Django est installé
```

### 4. Tester manuellement

```bash
cd /home/cp2639565p41/public_html
source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate
python manage.py check  # Vérifier la configuration Django
python manage.py runserver 0:8000  # Tester le serveur (puis Ctrl+C)
```

### 5. Redémarrer Passenger

```bash
touch ~/public_html/tmp/restart.txt
```

---

## ✅ CHECKLIST POST-DÉPLOIEMENT

Après chaque déploiement, vérifier :

- [ ] Les fichiers sont bien copiés dans `public_html`
- [ ] `passenger_wsgi.py` existe et est exécutable
- [ ] `.htaccess` pointe vers le bon virtualenv
- [ ] Les migrations sont appliquées : `python manage.py showmigrations`
- [ ] Les fichiers statiques sont collectés : `ls -la staticfiles/`
- [ ] Les permissions sont correctes : `chmod -R 755 public_html`
- [ ] L'application a été redémarrée : `touch tmp/restart.txt`
- [ ] Le site est accessible : https://aime-rdc.org

---

## 🆘 EN CAS DE PROBLÈME URGENT

### Rollback rapide :

```bash
cd /home/cp2639565p41/repositories/aime
git log --oneline  # Voir l'historique
git checkout <commit-hash-qui-fonctionnait>
cp -R * /home/cp2639565p41/public_html/
touch /home/cp2639565p41/public_html/tmp/restart.txt
```

### Contacter le support :

- **Support cPanel** : Via le panneau d'administration
- **Logs** : Toujours joindre le contenu de `~/logs/error_log`

---

## 📞 COMMANDES UTILES

```bash
# Vérifier le statut de l'application
curl -I https://aime-rdc.org

# Voir les processus Python
ps aux | grep python

# Espace disque
du -sh ~/public_html

# Dernières lignes du log
tail -f ~/logs/error_log  # Ctrl+C pour arrêter
```

---

## 🎯 RÉSUMÉ SIMPLIFIÉ

**Pour déployer après un push GitHub :**

```bash
ssh cp2639565p41@aime-rdc.org
cd /home/cp2639565p41/repositories/aime
git pull origin main
cd /home/cp2639565p41/public_html
bash post-deploy.sh
```

**Ça devrait fonctionner maintenant ! 🚀**

---

*Document créé le 5 octobre 2025*  
*Dernière mise à jour : Correction des erreurs 500 après déploiement*
