# Crop_and_Weed_Detector/urls.py
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('detector.urls')),  # Include our detection app routes under /api/
    path('admin_dashboard/', include('admin_dashboard.urls')),
    path('auth/', include('authentication.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)