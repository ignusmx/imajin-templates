"""
Celery tasks for the core application.
"""
from celery import shared_task
from django.core.mail import send_mail
from django.conf import settings
import time
import logging

logger = logging.getLogger(__name__)


@shared_task(bind=True)
def debug_task(self):
    """Debug task for testing Celery worker functionality."""
    logger.info(f'Request: {self.request!r}')
    return f'Task executed successfully! Request ID: {self.request.id}'


@shared_task
def sample_async_task(message="Hello from Celery!"):
    """Sample asynchronous task."""
    logger.info(f'Processing async task with message: {message}')
    time.sleep(2)  # Simulate some work
    return f'Task completed: {message}'


@shared_task
def send_email_task(subject, message, recipient_list):
    """Send email asynchronously."""
    try:
        send_mail(
            subject=subject,
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=recipient_list,
            fail_silently=False,
        )
        logger.info(f'Email sent successfully to {recipient_list}')
        return f'Email sent to {len(recipient_list)} recipients'
    except Exception as e:
        logger.error(f'Failed to send email: {str(e)}')
        raise


@shared_task
def periodic_cleanup_task():
    """Periodic task for cleanup operations."""
    logger.info('Running periodic cleanup task')
    # Add your cleanup logic here
    return 'Cleanup task completed'


@shared_task(bind=True, autoretry_for=(Exception,), retry_kwargs={'max_retries': 3, 'countdown': 60})
def resilient_task(self, data):
    """Task with automatic retry on failure."""
    try:
        logger.info(f'Processing resilient task with data: {data}')
        # Simulate potential failure
        if data.get('should_fail', False):
            raise ValueError('Simulated failure')
        return f'Resilient task completed successfully: {data}'
    except Exception as exc:
        logger.error(f'Task failed: {exc}')
        raise self.retry(exc=exc) 