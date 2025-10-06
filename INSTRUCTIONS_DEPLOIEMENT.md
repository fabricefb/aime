# 🚀 INSTRUCTIONS DE DÉPLOIEMENT - COPIER-COLLER

## ⚡ MÉTHODE RAPIDE (Recommandée)

### Étape 1 : Se connecter à votre serveur cPanel

Ouvrez un terminal et tapez :

```bash
ssh cp2639565p41@aime-rdc.org
```

Entrez votre mot de passe quand demandé.

---

### Étape 2 : Copier-coller le script complet

Une fois connecté, copiez et collez **TOUT LE BLOC CI-DESSOUS** dans votre terminal SSH :

```bash
cd /home/cp2639565p41/repositories/aime && \
git pull origin main && \
cp -R /home/cp2639565p41/repositories/aime/* /home/cp2639565p41/public_html/ && \
cp /home/cp2639565p41/repositories/aime/.htaccess /home/cp2639565p41/public_html/ && \
cd /home/cp2639565p41/public_html && \
source /home/cp2639565p41/virtualenv/public_html/3.9/bin/activate && \
pip install -r requirements.txt --quiet && \
python manage.py migrate --noinput && \
python manage.py collectstatic --noinput --clear && \
chmod -R 755 /home/cp2639565p41/public_html && \
mkdir -p /home/cp2639565p41/public_html/tmp && \
touch /home/cp2639565p41/public_html/tmp/restart.txt && \
echo "" && \
echo "✅ DÉPLOIEMENT TERMINÉ !" && \
echo "🌐 Ouvrez https://aime-rdc.org dans votre navigateur"
```

Appuyez sur **Entrée** et attendez que ça se termine (environ 1-2 minutes).

---

### Étape 3 : Vérifier que ça fonctionne

Dans le même terminal SSH, tapez :

```bash
curl -I https://aime-rdc.org
```

**Résultat attendu :** Vous devez voir `HTTP/2 200` ou `HTTP/1.1 200`

**Si vous voyez `500` :** Consultez les logs avec :

```bash
tail -n 50 ~/logs/error_log
```

---

## 🔍 VÉRIFICATION DANS LE NAVIGATEUR

1. Ouvrez : **https://aime-rdc.org**
2. ✅ La page doit s'afficher sans erreur 500
3. ✅ Les images et CSS doivent charger
4. ✅ Testez l'admin : **https://aime-rdc.org/admin**

---

## 🎯 SI VOUS VOULEZ PLUS DE DÉTAILS

Utilisez le script détaillé :

```bash
ssh cp2639565p41@aime-rdc.org
cd /home/cp2639565p41/repositories/aime
git pull origin main
bash deploy-manual.sh
```

Ce script affiche chaque étape avec des messages détaillés.

---

## ✅ C'EST TOUT !

Votre site devrait maintenant fonctionner sans erreur 500 après chaque push GitHub ! 🎉

---

## 🆘 EN CAS DE PROBLÈME

### Erreur : "git pull failed"

```bash
cd /home/cp2639565p41/repositories/aime
git status
```

Si des fichiers sont modifiés :

```bash
git stash
git pull origin main
```

---

### Erreur : "virtualenv not found"

Créez l'environnement virtuel via cPanel :
1. Aller dans **Setup Python App**
2. Créer une application Python 3.9
3. Application root : `/home/cp2639565p41/public_html`

---

### Erreur 500 persistante

Consultez les logs :

```bash
# Log Apache
tail -n 50 ~/logs/error_log

# Log WSGI (si le fichier existe)
cat ~/public_html/wsgi_error.log
```

Envoyez-moi le contenu des logs pour diagnostic.

---

### Redémarrage manuel

```bash
touch /home/cp2639565p41/public_html/tmp/restart.txt
```

Attendez 10-15 secondes puis rafraîchissez votre navigateur.

---

**🚀 COMMENCEZ MAINTENANT ! Copiez la commande de l'Étape 2 ci-dessus !**
