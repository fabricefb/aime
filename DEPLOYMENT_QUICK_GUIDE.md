# 🚀 GUIDE DE DÉPLOIEMENT RAPIDE - AIME OPTIMISÉ

## ⚡ DÉPLOIEMENT EN 5 MINUTES

### ÉTAPE 1 : Préparation serveur

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer les dépendances
sudo apt install python3-pip python3-venv redis-server postgresql postgresql-contrib -y

# Démarrer Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

### ÉTAPE 2 : Cloner et configurer

```bash
# Cloner le projet
git clone https://github.com/fabricefb/aime.git
cd aime

# Créer environnement virtuel
python3 -m venv venv
source venv/bin/activate

# Installer dépendances
pip install -r requirements.txt
```

### ÉTAPE 3 : Configuration .env

```bash
# Générer une SECRET_KEY
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Créer .env
nano .env
```

Copier cette configuration:

```bash
# PRODUCTION
SECRET_KEY=votre-secret-key-generee-ci-dessus
DEBUG=False
ALLOWED_HOSTS=votre-domaine.com,www.votre-domaine.com

# PostgreSQL (recommandé)
DATABASE_ENGINE=django.db.backends.postgresql
DATABASE_NAME=aime_db
DATABASE_USER=aime_user
DATABASE_PASSWORD=votre_mdp_db_securise
DATABASE_HOST=localhost
DATABASE_PORT=5432

# Redis
REDIS_URL=redis://127.0.0.1:6379/1

# Email
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=votre@email.com
EMAIL_HOST_PASSWORD=votre_mdp_email

# Security
CSRF_TRUSTED_ORIGINS=https://votre-domaine.com,https://www.votre-domaine.com
SECURE_SSL_REDIRECT=True
SECURE_HSTS_SECONDS=31536000
```

### ÉTAPE 4 : Base de données PostgreSQL

```bash
# Se connecter à PostgreSQL
sudo -u postgres psql

# Créer base de données et utilisateur
CREATE DATABASE aime_db;
CREATE USER aime_user WITH PASSWORD 'votre_mdp_db_securise';
ALTER ROLE aime_user SET client_encoding TO 'utf8';
ALTER ROLE aime_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE aime_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE aime_db TO aime_user;
\q
```

### ÉTAPE 5 : Migrations et collecte static

```bash
# Migrations
python manage.py migrate

# Créer superuser
python manage.py createsuperuser

# Collecter static files
python manage.py collectstatic --noinput

# Optimiser DB
python manage.py optimize_database --vacuum --analyze

# Premier backup
python manage.py backup_database --compress
```

### ÉTAPE 6 : Gunicorn

```bash
# Tester Gunicorn
gunicorn aimesite.wsgi:application --bind 0.0.0.0:8000

# Créer service systemd
sudo nano /etc/systemd/system/aime.service
```

Contenu du service:

```ini
[Unit]
Description=AIME Gunicorn daemon
After=network.target

[Service]
User=votre_user
Group=www-data
WorkingDirectory=/path/to/aime
Environment="PATH=/path/to/aime/venv/bin"
ExecStart=/path/to/aime/venv/bin/gunicorn \
          --workers 3 \
          --bind unix:/path/to/aime/aime.sock \
          aimesite.wsgi:application

[Install]
WantedBy=multi-user.target
```

```bash
# Démarrer le service
sudo systemctl start aime
sudo systemctl enable aime
```

### ÉTAPE 7 : Nginx

```bash
sudo nano /etc/nginx/sites-available/aime
```

Configuration Nginx:

```nginx
server {
    listen 80;
    server_name votre-domaine.com www.votre-domaine.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name votre-domaine.com www.votre-domaine.com;
    
    # SSL certificates (à configurer avec Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/votre-domaine.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/votre-domaine.com/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Static files
    location /static/ {
        alias /path/to/aime/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Media files
    location /media/ {
        alias /path/to/aime/media/;
        expires 30d;
    }
    
    # Proxy to Gunicorn
    location / {
        proxy_pass http://unix:/path/to/aime/aime.sock;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Activer le site
sudo ln -s /etc/nginx/sites-available/aime /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### ÉTAPE 8 : SSL avec Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com
```

### ÉTAPE 9 : Backups automatiques

```bash
# Créer script backup
sudo nano /usr/local/bin/backup-aime.sh
```

Contenu:

```bash
#!/bin/bash
cd /path/to/aime
source venv/bin/activate
python manage.py backup_database --compress
python manage.py optimize_database --analyze --clear-cache
```

```bash
# Rendre exécutable
sudo chmod +x /usr/local/bin/backup-aime.sh

# Ajouter au cron (tous les jours à 2h du matin)
sudo crontab -e
```

Ajouter:
```
0 2 * * * /usr/local/bin/backup-aime.sh >> /var/log/aime-backup.log 2>&1
```

### ÉTAPE 10 : Vérification finale

```bash
# Vérifier les services
sudo systemctl status aime
sudo systemctl status nginx
sudo systemctl status redis-server
sudo systemctl status postgresql

# Vérifier les logs
sudo journalctl -u aime -f
```

---

## 🎯 CHECKLIST POST-DÉPLOIEMENT

- [ ] Site accessible via HTTPS
- [ ] Certificat SSL valide
- [ ] Redis fonctionnel (`redis-cli ping` -> PONG)
- [ ] PostgreSQL connecté
- [ ] Static files chargés
- [ ] Admin accessible (/admin/)
- [ ] Backups configurés
- [ ] Logs fonctionnels

---

## 🔧 MAINTENANCE QUOTIDIENNE

```bash
# Voir les logs
sudo journalctl -u aime -n 50

# Redémarrer l'application
sudo systemctl restart aime

# Vider le cache
cd /path/to/aime && source venv/bin/activate
python manage.py shell -c "from django.core.cache import cache; cache.clear()"

# Optimiser DB
python manage.py optimize_database --vacuum --analyze
```

---

## 🚨 DÉPANNAGE

### Erreur 500
```bash
# Vérifier logs
sudo journalctl -u aime -n 100
tail -f /path/to/aime/logs/django.log
```

### Redis ne fonctionne pas
```bash
sudo systemctl status redis-server
redis-cli ping
```

### Base de données inaccessible
```bash
sudo -u postgres psql -c "SELECT version();"
```

---

**Temps total estimé**: 30-45 minutes  
**Prérequis**: Serveur Linux (Ubuntu/Debian), accès root, nom de domaine
