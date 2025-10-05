# Système d'Avis Visiteurs - Documentation

## 📋 Vue d'ensemble

Le système d'avis visiteurs permet de collecter automatiquement les retours et opinions des visiteurs du site web AIME. Une modal popup élégante s'affiche après 5 secondes de navigation pour inviter les visiteurs à partager leur avis.

## ✨ Fonctionnalités

### 1. **Modal de Bienvenue**
- Apparition automatique après 5 secondes
- Design moderne et attractif avec gradient bleu/violet
- Gestion intelligente des cookies pour ne pas afficher plusieurs fois

### 2. **Collecte d'Informations**
Le formulaire collecte :
- **Nom** (optionnel)
- **Email** (optionnel)
- **Téléphone** (optionnel)
- **Avis sur le site/projet** (requis)
- **Type de contribution souhaitée** (requis) :
  - Partager des idées
  - Devenir membre
  - Participer aux activités
  - Faire un don
  - Devenir partenaire
  - Autre
- **Détails supplémentaires** (optionnel)

### 3. **Métadonnées Automatiques**
Le système enregistre automatiquement :
- Adresse IP du visiteur
- User Agent (navigateur)
- Date et heure de soumission

### 4. **Gestion des Cookies**
- **Première visite** : Modal s'affiche après 5 secondes
- **Clic sur "Plus tard"** : Cookie de 7 jours, pas de réaffichage
- **Soumission du formulaire** : Cookie permanent de 365 jours

## 🎯 Utilisation

### Pour les Visiteurs
1. La modal apparaît automatiquement après 5 secondes
2. Remplir le formulaire (seuls l'avis et le type de contribution sont obligatoires)
3. Cliquer sur "Je donne mon avis" pour soumettre
4. Ou cliquer sur "Plus tard" pour reporter

### Pour les Administrateurs

#### Accéder aux Avis
1. Se connecter à l'interface d'administration Django : `/admin`
2. Naviguer vers **Main > Avis visiteurs**

#### Fonctionnalités Admin
- **Liste des avis** avec filtres par :
  - Type de contribution
  - Statut contacté
  - Date de création
- **Recherche** par nom, email, téléphone ou contenu de l'avis
- **Action groupée** : Marquer comme contacté
- **Détails complets** incluant :
  - Informations du visiteur
  - Avis et contribution souhaitée
  - Suivi (contacté, notes internes)
  - Métadonnées (IP, user agent)

## 🔧 Configuration Technique

### Fichiers Modifiés/Créés

1. **Models** : `/workspaces/aime/main/models.py`
   - Nouveau modèle `VisitorFeedback`

2. **Forms** : `/workspaces/aime/main/forms.py`
   - Nouveau formulaire `VisitorFeedbackForm`

3. **Views** : `/workspaces/aime/main/views.py`
   - Nouvelle vue `submit_visitor_feedback`

4. **URLs** : `/workspaces/aime/main/urls.py`
   - Nouvelle route `api/visitor-feedback/`

5. **Admin** : `/workspaces/aime/main/admin.py`
   - Configuration admin pour `VisitorFeedback`

6. **Templates** :
   - `/workspaces/aime/main/templates/main/visitor_feedback_modal.html`
   - Mise à jour de `/workspaces/aime/main/templates/main/home.html`

7. **Migration** : `main/migrations/0006_visitorfeedback.py`

### API Endpoint

**URL** : `/api/visitor-feedback/`
**Méthode** : POST
**Format** : FormData
**Réponse** : JSON

#### Exemple de requête réussie :
```json
{
  "success": true,
  "message": "Merci pour votre avis ! Nous vous contacterons bientôt."
}
```

#### Exemple de réponse d'erreur :
```json
{
  "success": false,
  "errors": {
    "opinion": ["Ce champ est obligatoire."],
    "contribution_type": ["Ce champ est obligatoire."]
  }
}
```

## 📧 Notifications Email

Lorsqu'un avis est soumis, un email de notification est automatiquement envoyé à l'équipe (si configuré dans les settings Django).

**Configuration requise dans settings.py** :
```python
CONTACT_EMAIL = 'contact@aime-rdc.org'
DEFAULT_FROM_EMAIL = 'noreply@aime-rdc.org'
```

## 🎨 Personnalisation

### Modifier le délai d'apparition
Dans `visitor_feedback_modal.html`, ligne ~149 :
```javascript
setTimeout(function() {
    const modal = new bootstrap.Modal(document.getElementById('visitorFeedbackModal'));
    modal.show();
}, 5000); // Changer 5000 (5 secondes)
```

### Modifier la durée du cookie "Plus tard"
Dans `visitor_feedback_modal.html`, ligne ~158 :
```javascript
setCookie('visitor_feedback_seen', 'later', 7); // Changer 7 (jours)
```

### Modifier le style
Le style de la modal peut être personnalisé dans la section `<style>` du fichier `visitor_feedback_modal.html`.

## 📊 Statistiques

Les administrateurs peuvent générer des statistiques sur :
- Nombre total d'avis reçus
- Répartition par type de contribution
- Taux de réponse
- Avis non encore traités

Exemple de requête dans le shell Django :
```python
from main.models import VisitorFeedback
from django.db.models import Count

# Total d'avis
total = VisitorFeedback.objects.count()

# Par type de contribution
by_type = VisitorFeedback.objects.values('contribution_type').annotate(count=Count('id'))

# Non contactés
not_contacted = VisitorFeedback.objects.filter(is_contacted=False).count()
```

## 🔒 Sécurité

- Protection CSRF activée
- Validation des données côté serveur
- Enregistrement de l'IP pour prévenir le spam
- Limite de taille des champs texte

## 🚀 Améliorations Futures

- [ ] Dashboard de statistiques dans l'admin
- [ ] Export CSV des avis
- [ ] Réponses automatiques par email
- [ ] Intégration CRM
- [ ] Analytics avancés
- [ ] A/B testing du texte de la modal
- [ ] Support multilingue
- [ ] Système de notation par étoiles

## 📝 Notes

- La modal utilise Bootstrap 5 pour le style et les interactions
- Font Awesome est utilisé pour les icônes
- Compatible avec tous les navigateurs modernes
- Responsive et mobile-friendly

## 🐛 Dépannage

### La modal ne s'affiche pas
1. Vérifier que Bootstrap 5 est bien chargé
2. Vérifier la console JavaScript pour les erreurs
3. Supprimer les cookies du site et rafraîchir

### Les avis ne sont pas enregistrés
1. Vérifier que la migration a été appliquée : `python manage.py migrate`
2. Vérifier les logs du serveur pour les erreurs
3. Tester l'endpoint directement avec un outil comme Postman

### Les emails ne sont pas envoyés
1. Vérifier la configuration EMAIL dans settings.py
2. Vérifier que CONTACT_EMAIL est défini
3. Consulter les logs du serveur

## 📞 Support

Pour toute question ou problème, contactez l'équipe technique AIME.
