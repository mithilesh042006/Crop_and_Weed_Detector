from django.contrib import admin
from .models import Tip, Disease, News

# Register models to Django Admin
admin.site.register(Tip)
admin.site.register(Disease)
admin.site.register(News)
