"""
Core views for Django Docker Template.
"""
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
import json


def home(request):
    """Home page view."""
    stats = {
        'users': 1250,
        'projects': 3400,
        'deployments': 15670,
        'uptime': '99.9%'
    }
    return render(request, 'core/welcome.html', {'stats': stats})


def about(request):
    """About page view."""
    features = [
        {
            'name': 'Docker-First Development',
            'description': 'Complete containerized development environment with hot reload',
            'icon': '🐳'
        },
        {
            'name': 'Modern Python Stack',
            'description': 'Python 3.11, Django 5, PostgreSQL, and Redis out of the box',
            'icon': '🚀'
        },
        {
            'name': 'Comprehensive Testing',
            'description': 'Pytest, code coverage, security audits, and performance tests',
            'icon': '🧪'
        },
        {
            'name': 'CI/CD Pipeline',
            'description': 'GitHub Actions with automated testing and deployment',
            'icon': '⚡'
        }
    ]
    return render(request, 'core/about.html', {'features': features})


def dashboard(request):
    """Dashboard page view."""
    recent_activity = [
        'Last login: 2 hours ago',
        'Project "E-commerce Site" deployed successfully',
        'Database backup completed',
        'SSL certificate renewed'
    ]
    return render(request, 'core/dashboard.html', {'recent_activity': recent_activity})


def health(request):
    """Health check endpoint."""
    return JsonResponse({
        'status': 'ok',
        'timestamp': str(request.timestamp) if hasattr(request, 'timestamp') else None,
        'service': 'Django Application'
    })


def phpinfo(request):
    """Python info endpoint (equivalent to phpinfo)."""
    if not settings.DEBUG:
        return JsonResponse({'error': 'Not available in production'}, status=403)
    
    import sys
    import django
    
    return JsonResponse({
        'python_version': sys.version,
        'django_version': django.get_version(),
        'debug': settings.DEBUG,
        'allowed_hosts': settings.ALLOWED_HOSTS,
        'installed_apps': settings.INSTALLED_APPS,
        'middleware': settings.MIDDLEWARE,
    })


def config_info(request):
    """Configuration information endpoint."""
    if not settings.DEBUG:
        return JsonResponse({'error': 'Not available in production'}, status=403)
    
    return JsonResponse({
        'app': {
            'debug': settings.DEBUG,
            'allowed_hosts': settings.ALLOWED_HOSTS,
            'time_zone': settings.TIME_ZONE,
        },
        'database': {
            'engine': settings.DATABASES['default']['ENGINE'],
            'name': settings.DATABASES['default']['NAME'],
            'host': settings.DATABASES['default']['HOST'],
            'port': settings.DATABASES['default']['PORT'],
        },
        'cache': {
            'backend': settings.CACHES['default']['BACKEND'],
            'location': settings.CACHES['default']['LOCATION'],
        },
    })


@csrf_exempt
def test_celery(request):
    """Test Celery task execution."""
    if not settings.DEBUG:
        return JsonResponse({'error': 'Not available in production'}, status=403)
    
    try:
        from .tasks import debug_task, sample_async_task
        
        # Trigger async tasks
        debug_result = debug_task.delay()
        sample_result = sample_async_task.delay("Test message from Django!")
        
        return JsonResponse({
            'status': 'success',
            'message': 'Celery tasks triggered successfully',
            'tasks': {
                'debug_task': {
                    'task_id': debug_result.id,
                    'status': debug_result.status
                },
                'sample_async_task': {
                    'task_id': sample_result.id,
                    'status': sample_result.status
                }
            }
        })
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'message': f'Failed to trigger Celery tasks: {str(e)}'
        }, status=500) 