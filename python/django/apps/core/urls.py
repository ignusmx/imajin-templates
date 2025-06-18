"""
Core URL patterns for Django Docker Template.
"""
from django.urls import path
from . import views

app_name = 'core'

urlpatterns = [
    # Home routes
    path('', views.home, name='home'),
    path('about/', views.about, name='about'),
    
    # Dashboard (requires authentication in real app)
    path('dashboard/', views.dashboard, name='dashboard'),
    
    # Health check route for Docker health checks
    path('health/', views.health, name='health'),
    
    # Simple info routes
    path('phpinfo/', views.phpinfo, name='phpinfo'),
    path('config/', views.config_info, name='config'),
    
    # Celery test endpoint
    path('test-celery/', views.test_celery, name='test_celery'),
] 