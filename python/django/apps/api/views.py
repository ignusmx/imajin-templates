"""
API views for Django Docker Template.
"""
import time
import psutil
import shutil
from datetime import datetime, timedelta
from django.http import JsonResponse
from django.core.cache import cache
from django.db import connection
from django.conf import settings
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from rest_framework.pagination import PageNumberPagination


@api_view(['GET'])
@permission_classes([AllowAny])
def api_status(request):
    """API status endpoint."""
    return Response({
        'status': 'success',
        'message': 'Django API is running!',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0',
        'environment': settings.DEBUG and 'development' or 'production',
        'uptime': get_uptime(),
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def api_health(request):
    """Health check endpoint for monitoring."""
    checks = {
        'database': check_database(),
        'cache': check_cache(),
        'storage': check_storage(),
    }

    is_healthy = all(check['status'] == 'ok' for check in checks.values())

    return Response({
        'status': 'healthy' if is_healthy else 'unhealthy',
        'checks': checks,
        'timestamp': datetime.now().isoformat(),
    }, status=status.HTTP_200_OK if is_healthy else status.HTTP_503_SERVICE_UNAVAILABLE)


@api_view(['GET'])
@permission_classes([AllowAny])
def api_stats(request):
    """Get application statistics."""
    stats = cache.get('app.stats')
    if not stats:
        stats = {
            'users_count': 1250,
            'active_users': 340,
            'total_requests': 45678,
            'avg_response_time': '120ms',
            'error_rate': '0.1%',
            'uptime_percentage': '99.9%',
            'last_deployment': (datetime.now() - timedelta(days=3)).isoformat(),
            'memory_usage': get_memory_usage(),
            'disk_usage': get_disk_usage(),
        }
        cache.set('app.stats', stats, 300)  # Cache for 5 minutes

    return Response({
        'status': 'success',
        'data': stats,
        'cached_at': cache.get('app.stats.timestamp', datetime.now().isoformat()),
    })


class ItemPagination(PageNumberPagination):
    """Custom pagination for items."""
    page_size = 15
    page_size_query_param = 'per_page'
    max_page_size = 100


@api_view(['GET'])
@permission_classes([AllowAny])
def api_items(request):
    """Sample CRUD endpoint - Get all items."""
    # Sample data
    items = [
        {'id': 1, 'name': 'Django Application', 'status': 'active', 'created_at': datetime.now() - timedelta(days=10)},
        {'id': 2, 'name': 'Docker Container', 'status': 'running', 'created_at': datetime.now() - timedelta(days=5)},
        {'id': 3, 'name': 'PostgreSQL Database', 'status': 'connected', 'created_at': datetime.now() - timedelta(days=3)},
        {'id': 4, 'name': 'Redis Cache', 'status': 'active', 'created_at': datetime.now() - timedelta(days=1)},
        {'id': 5, 'name': 'API Endpoints', 'status': 'operational', 'created_at': datetime.now()},
    ]

    # Apply search filter
    search = request.GET.get('search')
    if search:
        items = [item for item in items if search.lower() in item['name'].lower()]

    # Apply sorting
    sort_field = request.GET.get('sort', 'created_at')
    order = request.GET.get('order', 'desc')
    reverse = order == 'desc'
    
    if sort_field in ['name', 'created_at']:
        items.sort(key=lambda x: x[sort_field], reverse=reverse)

    # Pagination
    page = int(request.GET.get('page', 1))
    per_page = int(request.GET.get('per_page', 15))
    
    total = len(items)
    start = (page - 1) * per_page
    end = start + per_page
    paginated_items = items[start:end]

    # Convert datetime objects to ISO format
    for item in paginated_items:
        if isinstance(item['created_at'], datetime):
            item['created_at'] = item['created_at'].isoformat()

    return Response({
        'status': 'success',
        'data': paginated_items,
        'meta': {
            'current_page': page,
            'per_page': per_page,
            'total': total,
            'last_page': (total + per_page - 1) // per_page,
        },
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def api_create_item(request):
    """Sample POST endpoint - Create new item."""
    data = request.data

    # Validation
    if not data.get('name'):
        return Response({
            'status': 'error',
            'message': 'Validation failed',
            'errors': {'name': ['This field is required.']},
        }, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

    if not data.get('status') or data.get('status') not in ['active', 'inactive', 'pending']:
        return Response({
            'status': 'error',
            'message': 'Validation failed',
            'errors': {'status': ['This field is required and must be one of: active, inactive, pending.']},
        }, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

    # Create item
    item = {
        'id': int(time.time() * 1000) % 10000,  # Simple ID generation
        'name': data.get('name'),
        'description': data.get('description'),
        'status': data.get('status'),
        'created_at': datetime.now().isoformat(),
        'updated_at': datetime.now().isoformat(),
    }

    return Response({
        'status': 'success',
        'message': 'Item created successfully',
        'data': item,
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([AllowAny])
def api_webhook(request):
    """Sample webhook endpoint."""
    import logging
    logger = logging.getLogger(__name__)
    
    # Log the webhook payload
    logger.info('Webhook received', extra={'data': request.data})

    return Response({
        'status': 'success',
        'message': 'Webhook received',
        'received_at': datetime.now().isoformat(),
    })


def check_database():
    """Check database connectivity."""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        return {'status': 'ok', 'message': 'Database connection successful'}
    except Exception as e:
        return {'status': 'error', 'message': f'Database connection failed: {str(e)}'}


def check_cache():
    """Check cache connectivity."""
    try:
        cache.set('health_check', 'ok', 10)
        value = cache.get('health_check')
        return {'status': 'ok' if value == 'ok' else 'error', 
                'message': 'Cache is working' if value == 'ok' else 'Cache read/write failed'}
    except Exception as e:
        return {'status': 'error', 'message': f'Cache error: {str(e)}'}


def check_storage():
    """Check storage accessibility."""
    try:
        import tempfile
        import os
        
        with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
            f.write('test')
            temp_file = f.name
        
        with open(temp_file, 'r') as f:
            content = f.read()
        
        os.unlink(temp_file)
        
        return {'status': 'ok' if content == 'test' else 'error',
                'message': 'Storage is writable' if content == 'test' else 'Storage read/write failed'}
    except Exception as e:
        return {'status': 'error', 'message': f'Storage error: {str(e)}'}


def get_uptime():
    """Get application uptime."""
    return f"{30} days ago"  # Placeholder


def get_memory_usage():
    """Get memory usage information."""
    try:
        process = psutil.Process()
        memory_info = process.memory_info()
        return {
            'current': f"{memory_info.rss / 1024 / 1024:.2f} MB",
            'peak': f"{memory_info.vms / 1024 / 1024:.2f} MB",
            'available': f"{psutil.virtual_memory().available / 1024 / 1024:.2f} MB",
        }
    except:
        return {
            'current': 'N/A',
            'peak': 'N/A',
            'available': 'N/A',
        }


def get_disk_usage():
    """Get disk usage information."""
    try:
        usage = shutil.disk_usage('/')
        return {
            'free': f"{usage.free / 1024 / 1024 / 1024:.2f} GB",
            'total': f"{usage.total / 1024 / 1024 / 1024:.2f} GB",
            'used_percentage': f"{((usage.total - usage.free) / usage.total) * 100:.2f}%",
        }
    except:
        return {
            'free': 'N/A',
            'total': 'N/A',
            'used_percentage': 'N/A',
        } 