from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.core.paginator import Paginator
from django.db.models import Q, Sum
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
import json
from .models import (
    Project, Category, Event, MutotoBikeChallenge, MBCParticipant,
    ContactMessage, NewsletterSubscription, Donation, Staff,
    MutoScienceAdventure, ChatConversation, ChatMessage, User
)
from .forms import ContactForm, NewsletterForm, MBCRegistrationForm, DonationForm
from .utils import get_site_statistics

def home(request):
    """Page d'accueil AIME"""
    featured_projects = Project.objects.filter(is_featured=True, status='active')[:3]
    upcoming_events = Event.objects.filter(
        date__gte=timezone.now(),
        is_active=True
    ).order_by('date')[:3]
    
    recent_mbc = MutotoBikeChallenge.objects.filter(
        is_active=True,
        date__gte=timezone.now()
    ).first()
    
    # Statistiques dynamiques basées sur la vraie base de données
    stats = get_site_statistics()
    
    context = {
        'title': 'Agissons Ici et Maintenant pour les Enfants',
        'featured_projects': featured_projects,
        'upcoming_events': upcoming_events,
        'recent_mbc': recent_mbc,
        'stats': stats
    }
    return render(request, 'main/home.html', context)

def about(request):
    """Page à propos d'AIME"""
    staff_members = Staff.objects.filter(is_visible=True).select_related('user')[:6]
    
    context = {
        'title': 'À propos d\'AIME',
        'staff_members': staff_members,
    }
    return render(request, 'main/about.html', context)

def projects(request):
    """Liste des projets"""
    projects_list = Project.objects.filter(status='active').order_by('-created_at')
    categories = Category.objects.filter(is_active=True)
    
    # Filtrage par catégorie
    category_filter = request.GET.get('category')
    if category_filter:
        projects_list = projects_list.filter(category__slug=category_filter)
    
    # Recherche
    search_query = request.GET.get('search')
    if search_query:
        projects_list = projects_list.filter(
            Q(name__icontains=search_query) | 
            Q(description__icontains=search_query)
        )
    
    paginator = Paginator(projects_list, 9)
    page_number = request.GET.get('page')
    projects = paginator.get_page(page_number)
    
    context = {
        'title': 'Nos Projets',
        'projects': projects,
        'categories': categories,
        'current_category': category_filter,
        'search_query': search_query,
    }
    return render(request, 'main/projects.html', context)

def project_detail(request, slug):
    """Détail d'un projet"""
    project = get_object_or_404(Project, slug=slug)
    recent_donations = Donation.objects.filter(
        project=project,
        status='completed'
    ).order_by('-created_at')[:5]
    
    context = {
        'title': project.name,
        'project': project,
        'recent_donations': recent_donations,
    }
    return render(request, 'main/project_detail.html', context)

def mutoto_bike_challenge(request):
    """Page principale du Mutoto Bike Challenge"""
    current_event = MutotoBikeChallenge.objects.filter(
        is_active=True,
        date__gte=timezone.now()
    ).first()
    
    past_events = MutotoBikeChallenge.objects.filter(
        date__lt=timezone.now()
    ).order_by('-date')[:3]
    
    # Activités scientifiques actives
    science_activities = MutoScienceAdventure.objects.filter(
        is_active=True,
        start_date__lte=timezone.now().date(),
        end_date__gte=timezone.now().date()
    )[:3]
    
    context = {
        'title': 'Mutoto Bike Challenge',
        'current_event': current_event,
        'past_events': past_events,
        'science_activities': science_activities,
    }
    return render(request, 'main/mbc.html', context)

def mbc_registration(request):
    """Inscription au Mutoto Bike Challenge"""
    current_event = MutotoBikeChallenge.objects.filter(
        is_active=True,
        date__gte=timezone.now()
    ).first()
    
    if not current_event:
        messages.error(request, "Aucun événement ouvert aux inscriptions actuellement.")
        return redirect('main:mutoto_bike_challenge')
    
    if request.method == 'POST':
        form = MBCRegistrationForm(request.POST)
        if form.is_valid():
            participant = form.save(commit=False)
            participant.event = current_event
            participant.save()
            messages.success(
                request, 
                f"Inscription réussie pour {participant.participant_name}! "
                "Vous recevrez une confirmation par email."
            )
            return redirect('main:mutoto_bike_challenge')
    else:
        form = MBCRegistrationForm()
    
    context = {
        'title': 'Inscription MBC',
        'form': form,
        'event': current_event,
    }
    return render(request, 'main/mbc_registration.html', context)

def events(request):
    """Liste des événements"""
    events_list = Event.objects.filter(
        is_active=True,
        date__gte=timezone.now()
    ).order_by('date')
    
    paginator = Paginator(events_list, 12)
    page_number = request.GET.get('page')
    events = paginator.get_page(page_number)
    
    context = {
        'title': 'Événements',
        'events': events,
    }
    return render(request, 'main/events.html', context)

def event_detail(request, slug):
    """Détail d'un événement"""
    event = get_object_or_404(Event, slug=slug, is_public=True)
    
    context = {
        'title': event.title,
        'event': event,
    }
    return render(request, 'main/event_detail.html', context)

def contact(request):
    """Page de contact"""
    if request.method == 'POST':
        form = ContactForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(
                request, 
                "Votre message a été envoyé avec succès! "
                "Nous vous répondrons dans les plus brefs délais."
            )
            return redirect('main:contact')
    else:
        form = ContactForm()
    
    context = {
        'title': 'Contact',
        'form': form,
    }
    return render(request, 'main/contact.html', context)

def donate(request, project_slug=None):
    """Page de don"""
    project = None
    if project_slug:
        project = get_object_or_404(Project, slug=project_slug)
    
    if request.method == 'POST':
        form = DonationForm(request.POST)
        if form.is_valid():
            donation = form.save(commit=False)
            if project:
                donation.project = project
            donation.save()
            messages.success(
                request,
                "Votre don a été enregistré! "
                "Vous recevrez les instructions de paiement par email."
            )
            return redirect('main:donate_success')
    else:
        form = DonationForm(initial={'project': project} if project else None)
    
    context = {
        'title': 'Faire un don',
        'form': form,
        'project': project,
    }
    return render(request, 'main/donate.html', context)

def donate_success(request):
    """Page de confirmation de don"""
    context = {
        'title': 'Don confirmé',
    }
    return render(request, 'main/donate_success.html', context)

def newsletter_subscribe(request):
    """Abonnement newsletter (AJAX)"""
    if request.method == 'POST':
        email = request.POST.get('email')
        name = request.POST.get('name', '')
        
        if email:
            subscription, created = NewsletterSubscription.objects.get_or_create(
                email=email,
                defaults={'name': name}
            )
            
            if created:
                return JsonResponse({'success': True, 'message': 'Abonnement réussi!'})
            else:
                return JsonResponse({'success': False, 'message': 'Email déjà abonné.'})
    
    return JsonResponse({'success': False, 'message': 'Erreur lors de l\'abonnement.'})

@login_required
def dashboard(request):
    """Dashboard utilisateur"""
    user_donations = Donation.objects.filter(
        donor_email=request.user.email
    ).order_by('-created_at')[:5]
    
    user_messages = ContactMessage.objects.filter(
        email=request.user.email
    ).order_by('-created_at')[:5]
    
    context = {
        'title': 'Mon Tableau de Bord',
        'user_donations': user_donations,
        'user_messages': user_messages,
    }
    return render(request, 'main/dashboard.html', context)


def impact_theory(request):
    """Page Théorie du Changement"""
    context = {
        'title': 'Notre Théorie du Changement',
    }
    return render(request, 'main/impact_theory.html', context)


def observatory(request):
    """Page Observatoire des Droits de l'Enfant"""
    context = {
        'title': 'Observatoire des Droits de l\'Enfant',
    }
    return render(request, 'main/observatory.html', context)


def research_center(request):
    """Page Centre de Recherche & Innovation"""
    context = {
        'title': 'Centre de Recherche & Innovation',
    }
    return render(request, 'main/research_center.html', context)


def manifesto(request):
    """Page Manifeste AIME"""
    context = {
        'title': 'Manifeste AIME - Notre Vision pour l\'Afrique',
    }
    return render(request, 'main/manifesto.html', context)


# --- Chat Assistant Views ---
@csrf_exempt
@require_POST
def chat_notification(request):
    """Gère les notifications de chat pour assistance humaine"""
    try:
        data = json.loads(request.body)
        user_message = data.get('message', '')
        conversation_history = data.get('history', '')
        user_email = data.get('email', 'visiteur@site.com')
        user_name = data.get('name', 'Visiteur')

        # Créer ou récupérer une conversation
        # Pour les utilisateurs non connectés, on utilise un utilisateur temporaire
        try:
            user = User.objects.get(email=user_email)
        except User.DoesNotExist:
            # Créer un utilisateur temporaire pour les visiteurs
            user, created = User.objects.get_or_create(
                username=f"visitor_{user_email.replace('@', '_').replace('.', '_')}",
                defaults={
                    'email': user_email,
                    'first_name': user_name,
                    'is_active': False  # Utilisateur temporaire
                }
            )

        # Créer une nouvelle conversation si nécessaire
        conversation, created = ChatConversation.objects.get_or_create(
            user=user,
            closed=False,
            defaults={'staff': None}
        )

        # Sauvegarder le message de l'utilisateur
        ChatMessage.objects.create(
            conversation=conversation,
            sender=user,
            content=user_message,
            is_assistant=False
        )

        # Envoyer notification par email
        send_chat_notification_email(
            user_name=user_name,
            user_email=user_email,
            message=user_message,
            conversation_history=conversation_history,
            conversation_id=conversation.id
        )

        return JsonResponse({
            'success': True,
            'message': 'Notification envoyée avec succès'
        })

    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        }, status=500)


def send_chat_notification_email(user_name, user_email, message, conversation_history, conversation_id):
    """Envoie une notification par email pour une demande d'assistance humaine"""
    subject = f"🆘 AIDE REQUISE - Nouveau message chat de {user_name}"

    # Construire le corps de l'email
    body = f"""
Bonjour l'équipe AIME,

Un visiteur a demandé de l'assistance humaine via le chat en ligne.

📋 DÉTAILS DE LA CONVERSATION :
=====================================

👤 Visiteur : {user_name}
📧 Email : {user_email}
🆔 Conversation ID : {conversation_id}
⏰ Date/Heure : {timezone.now().strftime('%d/%m/%Y %H:%M')}

💬 DERNIER MESSAGE :
{message}

📚 HISTORIQUE DE LA CONVERSATION :
{conversation_history if conversation_history else "Première interaction"}

🔗 ACTIONS RECOMMANDÉES :
1. Connectez-vous au panneau d'administration
2. Accédez à la section "Chat Conversations"
3. Répondez à la conversation #{conversation_id}
4. Ou contactez directement le visiteur à : {user_email}

Cordialement,
🤖 Assistant AIME
Site Web : https://aime-rdc.org
    """

    try:
        # Envoyer l'email
        send_mail(
            subject=subject,
            message=body,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=['contact@aime-rdc.org'],  # Email fourni par l'utilisateur
            fail_silently=False
        )
        print(f"✅ Email de notification envoyé pour la conversation #{conversation_id}")
    except Exception as e:
        print(f"❌ Erreur lors de l'envoi de l'email : {e}")


@login_required
def chat_admin(request):
    """Interface d'administration du chat pour le staff"""
    if not request.user.is_staff:
        messages.error(request, "Accès réservé au personnel autorisé.")
        return redirect('main:home')

    # Conversations actives
    active_conversations = ChatConversation.objects.filter(
        closed=False
    ).select_related('user', 'staff').order_by('-created_at')

    # Messages récents
    recent_messages = ChatMessage.objects.filter(
        conversation__closed=False
    ).select_related('conversation', 'sender').order_by('-timestamp')[:20]

    context = {
        'title': 'Administration Chat',
        'active_conversations': active_conversations,
        'recent_messages': recent_messages,
    }

    return render(request, 'main/chat_admin.html', context)


@login_required
@require_POST
def chat_reply(request, conversation_id):
    """Répondre à une conversation de chat"""
    if not request.user.is_staff:
        return JsonResponse({'success': False, 'error': 'Accès non autorisé'})

    try:
        conversation = get_object_or_404(ChatConversation, id=conversation_id)
        message_content = request.POST.get('message', '').strip()

        if not message_content:
            return JsonResponse({'success': False, 'error': 'Message vide'})

        # Créer le message du staff
        ChatMessage.objects.create(
            conversation=conversation,
            sender=request.user,
            content=message_content,
            is_assistant=False
        )

        # Assigner le staff à la conversation si pas encore fait
        if not conversation.staff:
            conversation.staff = request.user
            conversation.save()

        return JsonResponse({
            'success': True,
            'message': 'Réponse envoyée avec succès'
        })

    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        }, status=500)


@login_required
@require_POST
def close_conversation(request, conversation_id):
    """Fermer une conversation de chat"""
    if not request.user.is_staff:
        return JsonResponse({'success': False, 'error': 'Accès non autorisé'})

    try:
        conversation = get_object_or_404(ChatConversation, id=conversation_id)
        conversation.closed = True
        conversation.save()

        return JsonResponse({
            'success': True,
            'message': 'Conversation fermée'
        })

    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        }, status=500)
