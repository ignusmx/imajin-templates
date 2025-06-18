"""
Pytest configuration and fixtures for Django testing.
"""

import pytest
from django.test import Client


@pytest.fixture
def client():
    """Django test client fixture."""
    return Client()


@pytest.fixture
def api_client():
    """API client fixture with JSON content type."""
    client = Client()
    client.defaults['HTTP_ACCEPT'] = 'application/json'
    client.defaults['CONTENT_TYPE'] = 'application/json'
    return client


@pytest.fixture
def authenticated_client(django_user_model):
    """Authenticated client fixture."""
    user = django_user_model.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )
    client = Client()
    client.force_login(user)
    return client, user 