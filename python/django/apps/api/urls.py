"""
API URL patterns for Django Docker Template.
"""
from django.urls import path
from . import views

app_name = 'api'

urlpatterns = [
    # Public API endpoints
    path('status/', views.api_status, name='status'),
    path('health/', views.api_health, name='health'),
    path('stats/', views.api_stats, name='stats'),
    
    # Sample CRUD endpoints
    path('items/', views.api_items, name='items'),
    path('items/create/', views.api_create_item, name='create_item'),
    
    # Sample webhook endpoint
    path('webhook/', views.api_webhook, name='webhook'),
]

# Fallback for undefined API endpoints
from django.http import JsonResponse
from django.urls import reverse

def api_fallback(request, exception=None):
    """Fallback view for undefined API endpoints."""
    return JsonResponse({
        'status': 'error',
        'message': 'API endpoint not found',
        'documentation': request.build_absolute_uri(reverse('api:status')),
    }, status=404) 