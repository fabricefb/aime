# 🚀 AIME RDC - Site Web Complet

## 📋 Description
Site web complet de l'Association Internationale pour les Enfants (AIME) - RDC, développé avec Django.

## 🎯 Fonctionnalités
- ✅ Système de chat avec support humain
- ✅ Interface d'administration complète
- ✅ Gestion des utilisateurs et authentification
- ✅ Pages statiques optimisées
- ✅ API REST pour les données
- ✅ Interface responsive mobile

## 📦 Déploiement cPanel

### 📁 Fichiers de déploiement
Les fichiers suivants sont disponibles dans le workspace GitHub Codespaces :

1. **`aime-rdc-cpanel-deployment.zip`** (151 MB) - Archive complète du projet
2. **`deployment-complete.zip`** (145 MB) - Archive avec tous les fichiers de déploiement

### 💻 Comment obtenir les archives :

#### Méthode 1 : Via GitHub Codespaces
```bash
# Dans le workspace GitHub Codespaces
cd /workspaces/aime-rdc.org
ls -lh *.zip
```

#### Méthode 2 : Via VS Code
1. Ouvrir l'explorateur de fichiers
2. Télécharger `aime-rdc-cpanel-deployment.zip`
3. Télécharger `deployment-complete.zip`

#### Méthode 3 : Via Terminal
```bash
# Créer une nouvelle archive si nécessaire
zip -r deployment-files.zip .htaccess passenger_wsgi.py .env.production requirements.txt GUIDE_DEPLOIEMENT_CPANEL.md
```

### 📋 Guide d'installation
Consultez le fichier `GUIDE_DEPLOIEMENT_CPANEL.md` pour les instructions complètes.

## 🔧 Technologies utilisées
- **Backend** : Django 4.2.14
- **Base de données** : SQLite (développement) / MySQL (production)
- **Frontend** : HTML5, CSS3, JavaScript
- **Serveur** : Apache (cPanel) avec mod_wsgi

## 🚀 Démarrage rapide

### Prérequis
- Python 3.9+
- pip
- virtualenv

### Installation
```bash
# Cloner le repository
git clone https://github.com/fabricefb/aime-rdc.org
cd aime-rdc.org

# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou venv\Scripts\activate  # Windows

# Installer les dépendances
pip install -r requirements.txt

# Appliquer les migrations
python manage.py migrate

# Créer un superutilisateur
python manage.py createsuperuser

# Collecter les fichiers statiques
python manage.py collectstatic

# Lancer le serveur
python manage.py runserver
```

## 📞 Support
Pour toute question concernant le déploiement ou l'utilisation :
- Consulter le `GUIDE_DEPLOIEMENT_CPANEL.md`
- Vérifier les logs d'erreur
- Tester les permissions des fichiers

## 📝 Note importante
Les archives ZIP volumineuses sont exclues du repository GitHub en raison des limites de taille (100MB). Elles sont disponibles dans le workspace GitHub Codespaces et doivent être téléchargées séparément pour le déploiement.

---
**🎉 Site AIME RDC - Prêt pour le déploiement !**