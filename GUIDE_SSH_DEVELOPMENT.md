# 🔧 GUIDE RAPIDE POUR VOIR LES MODIFICATIONS EN SSH

## � Chemins importants :
- Site : `/home/cp2639565p41/aime-rdc.org`
- Virtualenv : `/home/cp2639565p41/virtualenv/aime-rdc.org/3.9/bin/activate`

## �🚀 Commandes essentielles après chaque modification :

### ⚡ **Redémarrage rapide (utilisez ceci après chaque modification) :**
```bash
cd /home/cp2639565p41/aime-rdc.org
./restart-site.sh
```

### 🔄 **Commandes manuelles si le script ne fonctionne pas :**
```bash
# 1. Collecter les fichiers statiques
python3 manage.py collectstatic --noinput

# 2. Redémarrer l'application (pour cPanel/Passenger)
touch tmp/restart.txt

# 3. Vider le cache navigateur (optionnel)
python3 manage.py collectstatic --clear --noinput
python3 manage.py collectstatic --noinput
```

### 👀 **Mode surveillance automatique :**
```bash
cd /home/cp2639565p41/aime-rdc.org
./dev-watch.sh
```

## 📝 **Workflow recommandé :**

1. **Modifier vos fichiers** (templates, CSS, JS, etc.)
2. **Exécuter :** `./restart-site.sh`
3. **Actualiser la page** dans votre navigateur
4. **Répéter** pour chaque modification

## 🐛 **Si les modifications ne s'affichent toujours pas :**

### Vérifier les permissions :
```bash
chmod -R 755 staticfiles/
chmod -R 755 main/static/
```

### Forcer le rechargement :
```bash
# Supprimer le cache navigateur
python3 manage.py collectstatic --clear --noinput
python3 manage.py collectstatic --noinput

# Redémarrer complètement
touch tmp/restart.txt
mkdir -p tmp && touch tmp/restart.txt
```

### Vérifier les logs d'erreur :
```bash
# Voir les logs d'erreur
tail -f ~/logs/aime-rdc.org_error_log
```

## ⚙️ **Configuration pour développement permanent :**

### Utiliser les paramètres debug :
```bash
# Modifier passenger_wsgi.py pour utiliser debug_settings
export DJANGO_SETTINGS_MODULE=aimesite.debug_settings
```

### Ou modifier passenger_wsgi.py directement :
```python
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'aimesite.debug_settings')
```

## 🌐 **URLs importantes :**
- **Site live :** https://aime-rdc.org
- **Admin :** https://aime-rdc.org/admin/
- **Test images :** https://aime-rdc.org/test-images/

---

💡 **Astuce :** Gardez un terminal ouvert avec `./dev-watch.sh` pendant que vous développez !