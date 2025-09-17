# Configuration temporaire pour debug l'erreur 500
# À utiliser TEMPORAIREMENT pour diagnostiquer, puis remettre DEBUG=False

from .settings import *
import os
import pymysql

# Configure PyMySQL to work with Django MySQL backend
pymysql.install_as_MySQLdb()

# DEBUG TEMPORAIRE POUR DIAGNOSTIC
DEBUG = True  # ⚠️ ATTENTION: Remettre à False après diagnostic
ALLOWED_HOSTS = ['aime-rdc.org', 'www.aime-rdc.org', '127.0.0.1', 'localhost', '*']

# Configuration timezone pour éviter les erreurs de timestamp
USE_TZ = True
TIME_ZONE = 'Africa/Kinshasa'  # Timezone RDC

# Configuration pour le développement - Auto-reload des templates et fichiers statiques
TEMPLATES[0]['OPTIONS']['context_processors'].append('django.template.context_processors.debug')
TEMPLATES[0]['OPTIONS']['debug'] = True

# Désactiver le cache pour voir les changements immédiatement
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    }
}

# Reload automatique des fichiers statiques
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'

# Base de données MySQL avec PyMySQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'cp2639565p41_aimer2639565',
        'USER': 'cp2639565p41_aimer2639565',
        'PASSWORD': 'Wazenga007@bd',
        'HOST': 'localhost',
        'PORT': '3306',
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
        },
        'CONN_MAX_AGE': 60,
    }
}

# Fichiers statiques et médias pour la production
STATIC_URL = '/static/'
STATIC_ROOT = '/home/cp2639565p41/aime-rdc/staticfiles/'
MEDIA_URL = '/media/'
MEDIA_ROOT = '/home/cp2639565p41/aime-rdc/media/'

# Logging détaillé pour debug
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'level': 'ERROR',
            'class': 'logging.FileHandler',
            'filename': '/home/cp2639565p41/aime-rdc/debug.log',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'DEBUG',
    },
}

print("⚠️ MODE DEBUG ACTIVÉ - Remettre DEBUG=False après diagnostic")
