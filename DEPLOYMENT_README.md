# 🚀 Outils de Déploiement AIME RDC - cPanel

Ce fichier contient les outils nécessaires pour déployer l'application AIME RDC sur un hébergement cPanel.

## 📦 Génération du Package de Déploiement

Pour créer un package de déploiement prêt pour cPanel :

```bash
python deploy_to_cpanel.py
```

### Ce que fait le script :

1. **Crée un dossier `deployment_package/`** avec tous les fichiers nécessaires
2. **Génère une archive ZIP** `deployment_package.zip` 
3. **Inclut la documentation complète** de déploiement
4. **Configure automatiquement** les fichiers pour cPanel

### Contenu du package généré :

- ✅ **Application Django complète** (aimesite/, main/)
- ✅ **Configuration production** (passenger_wsgi.py, production_settings.py)
- ✅ **Fichiers statiques** pré-collectés
- ✅ **Configuration Apache** (.htaccess)
- ✅ **Documentation** (guide détaillé + instructions)
- ✅ **Script de vérification** (verify_cpanel.py)

## 🎯 Déploiement sur cPanel

1. Exécutez `python deploy_to_cpanel.py`
2. Téléchargez `deployment_package.zip`
3. Suivez le guide `GUIDE_DEPLOYMENT_CPANEL.md` inclus dans le package

## ⚙️ Configuration Pré-configurée

- **Utilisateur cPanel** : `cp2639565p41`
- **Base de données** : `cp2639565p41_aimer2639565`
- **Domaine** : `aime-rdc.org`
- **Python** : 3.9
- **Environnement virtuel** : `/home/cp2639565p41/virtualenv/aime/3.9`

## 📋 Prérequis

- Python 3.9 activé sur cPanel
- Base de données MySQL configurée
- Accès FTP ou gestionnaire de fichiers cPanel

---

*Généré automatiquement le 17 octobre 2025*