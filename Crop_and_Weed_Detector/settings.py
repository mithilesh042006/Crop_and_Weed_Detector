"""
settings.py for Crop_and_Weed_Detector
"""

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-qb3ew*69m%hfcn)89h1#r@rq6nnx7q9u^effb=a%p%=zu@ojs1'
DEBUG = True
ALLOWED_HOSTS = []

# -----------------------------------------
# AUTH & SESSION SETTINGS
# -----------------------------------------
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',  # Standard Django auth
]

SESSION_ENGINE = "django.contrib.sessions.backends.db"  # Database sessions
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_SECURE = False  # True if using HTTPS

# **Important**: If you remove `@login_required`, setting this to None is safe.
LOGIN_URL = "/auth/admin_login"  # Prevents auto-redirect if any leftover @login_required is triggered

# Use your custom User model if defined
AUTH_USER_MODEL = 'authentication.CustomUser'

# -----------------------------------------
# APPLICATION DEFINITION
# -----------------------------------------
INSTALLED_APPS = [
    'corsheaders',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'detector',
    'admin_dashboard',
    'authentication',
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'Crop_and_Weed_Detector.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'Crop_and_Weed_Detector.wsgi.application'

# -----------------------------------------
# DATABASE
# -----------------------------------------
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# -----------------------------------------
# PASSWORD VALIDATION
# -----------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# -----------------------------------------
# CORS & CSRF
# -----------------------------------------
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",  # Example React dev server
]

CSRF_TRUSTED_ORIGINS = [
    "http://localhost:5173",
]

CORS_ALLOW_CREDENTIALS = True  # If you ever want to send cookies automatically

# -----------------------------------------
# INTERNATIONALIZATION
# -----------------------------------------
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# -----------------------------------------
# STATIC & MEDIA
# -----------------------------------------
STATIC_URL = 'static/'
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
