# 🚀 GUIDE DE MIGRATION POSTGRESQL POUR AIME
**Date** : 30 octobre 2025  
**Objectif** : Migrer de SQLite vers PostgreSQL pour performance et stabilité

---

## 📋 ÉTAPE 1 : INSTALLER POSTGRESQL

### Sur Ubuntu/Debian :
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Sur macOS :
```bash
brew install postgresql
brew services start postgresql
```

### Sur Windows :
Télécharger depuis : https://www.postgresql.org/download/windows/

---

## 📋 ÉTAPE 2 : CRÉER LA BASE DE DONNÉES

```bash
# Se connecter à PostgreSQL
sudo -u postgres psql

# Créer l'utilisateur
CREATE USER aime_user WITH PASSWORD 'VotreMotDePasseSecurise123!';

# Créer la base de données
CREATE DATABASE aime_db OWNER aime_user;

# Donner tous les privilèges
GRANT ALL PRIVILEGES ON DATABASE aime_db TO aime_user;

# Quitter
\q
```

---

## 📋 ÉTAPE 3 : SAUVEGARDER LES DONNÉES SQLITE

```bash
cd /workspaces/aime

# Créer un répertoire de backup
mkdir -p backups

# Exporter toutes les données
python manage.py dumpdata \
    --natural-foreign \
    --natural-primary \
    -e contenttypes \
    -e auth.Permission \
    --indent 4 \
    -o backups/backup_$(date +%Y%m%d_%H%M%S).json

# Vérifier que le fichier existe et n'est pas vide
ls -lh backups/
```

---

## 📋 ÉTAPE 4 : CONFIGURER .ENV POUR POSTGRESQL

Modifier `/workspaces/aime/.env` :

```env
# Commenter/désactiver SQLite
# DATABASE_ENGINE=django.db.backends.sqlite3
# DATABASE_NAME=db.sqlite3

# Activer PostgreSQL
DATABASE_ENGINE=django.db.backends.postgresql
DATABASE_NAME=aime_db
DATABASE_USER=aime_user
DATABASE_PASSWORD=VotreMotDePasseSecurise123!
DATABASE_HOST=localhost
DATABASE_PORT=5432
```

---

## 📋 ÉTAPE 5 : MIGRER LES DONNÉES

```bash
cd /workspaces/aime

# Vérifier la connexion PostgreSQL
python manage.py check --database default

# Créer les tables dans PostgreSQL
python manage.py migrate

# Importer les données depuis le backup
python manage.py loaddata backups/backup_YYYYMMDD_HHMMSS.json

# Vérifier que tout fonctionne
python manage.py runserver
```

---

## 📋 ÉTAPE 6 : VÉRIFICATIONS POST-MIGRATION

```bash
# Vérifier les utilisateurs
python manage.py shell
>>> from django.contrib.auth.models import User
>>> User.objects.count()

# Vérifier les projets
>>> from main.models import Project
>>> Project.objects.count()

# Vérifier les dons
>>> from main.models import Donation
>>> Donation.objects.count()

# Quitter
>>> exit()
```

---

## 📋 ÉTAPE 7 : OPTIMISATION POSTGRESQL

Créer un fichier de commande de maintenance :

```bash
# Fichier : /workspaces/aime/main/management/commands/optimize_db.py
```

Voir le code dans le fichier ci-dessus.

Exécuter :
```bash
python manage.py optimize_db
```

---

## 🔧 RÉSOLUTION DE PROBLÈMES

### Erreur : "connection refused"
```bash
# Vérifier que PostgreSQL est démarré
sudo systemctl status postgresql

# Redémarrer si nécessaire
sudo systemctl restart postgresql
```

### Erreur : "password authentication failed"
```bash
# Réinitialiser le mot de passe
sudo -u postgres psql
ALTER USER aime_user WITH PASSWORD 'NouveauMotDePasse';
\q

# Mettre à jour .env avec le nouveau mot de passe
```

### Erreur : "database does not exist"
```bash
# Recréer la base
sudo -u postgres psql
CREATE DATABASE aime_db OWNER aime_user;
\q
```

---

## ⚡ PERFORMANCES ATTENDUES

**Avant (SQLite)** :
- ⏱️ Requêtes complexes : 500-1000ms
- 👥 Utilisateurs simultanés max : 10-20
- 💾 Risque de corruption : Élevé
- 🔄 Concurrence : Aucune

**Après (PostgreSQL)** :
- ⚡ Requêtes complexes : 50-100ms (10x plus rapide)
- 🚀 Utilisateurs simultanés : 1000+
- 🛡️ Intégrité des données : Garantie
- ✅ Transactions ACID : Complètes
- 📊 Index avancés : Supportés

---

## 📝 CHECKLIST FINALE

- [ ] PostgreSQL installé et démarré
- [ ] Base de données `aime_db` créée
- [ ] Utilisateur `aime_user` créé avec mot de passe
- [ ] Backup SQLite créé dans `/backups/`
- [ ] `.env` configuré avec PostgreSQL
- [ ] `python manage.py migrate` exécuté sans erreur
- [ ] Données importées avec `loaddata`
- [ ] Tests de vérification passés
- [ ] Site accessible sur http://localhost:8000
- [ ] Anciennes données visibles

---

## 🎯 PROCHAINES ÉTAPES

Après la migration PostgreSQL, passer à :
1. ✅ Optimisation des requêtes (select_related, prefetch_related)
2. ✅ Ajout d'index sur les modèles
3. ✅ Configuration du cache Redis
4. ✅ Compression des fichiers statiques

---

**Support** : En cas de problème, consulter la documentation Django :
https://docs.djangoproject.com/en/4.2/ref/databases/#postgresql-notes
