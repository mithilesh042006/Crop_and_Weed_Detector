from django.urls import path
from . import views

urlpatterns = [
    path('upload', views.upload_image, name='upload_image'),      # POST
    path('delete', views.delete_image, name='delete_image'),      # DELETE
    path('history', views.history_view, name='history_view'),     # GET
    path('tips', views.tips_view, name='tips_view'),              # POST
    path('diseases', views.diseases_view, name='diseases_view'),  # POST
    path('news', views.news_view, name='news_view'),              # POST
]
