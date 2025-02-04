from django.urls import path
from .views import (
    add_or_update_tip, delete_tip,
    add_or_update_disease, delete_disease,
    add_or_update_news, delete_news
)

urlpatterns = [
    path('add_tip', add_or_update_tip, name='add_tip'),
    path('delete_tip', delete_tip, name='delete_tip'),
    
    path('add_disease', add_or_update_disease, name='add_disease'),
    path('delete_disease', delete_disease, name='delete_disease'),
    
    path('add_news', add_or_update_news, name='add_news'),
    path('delete_news', delete_news, name='delete_news'),
]
