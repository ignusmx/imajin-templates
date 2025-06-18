"""
Unit tests for core views.
"""

import pytest
from django.urls import reverse
from django.test import TestCase


class CoreViewsTestCase(TestCase):
    """Test cases for core application views."""

    def test_home_view(self):
        """Test home page view."""
        response = self.client.get(reverse('core:home'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Welcome to Django')

    def test_about_view(self):
        """Test about page view."""
        response = self.client.get(reverse('core:about'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'About This Django Template')

    def test_dashboard_view(self):
        """Test dashboard page view."""
        response = self.client.get(reverse('core:dashboard'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Dashboard')

    def test_health_view(self):
        """Test health check view."""
        response = self.client.get(reverse('core:health'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')

    def test_config_view(self):
        """Test configuration view."""
        response = self.client.get(reverse('core:config'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')

    def test_phpinfo_view(self):
        """Test phpinfo equivalent view."""
        response = self.client.get(reverse('core:phpinfo'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')


@pytest.mark.django_db
class TestCoreViews:
    """Pytest-style tests for core views."""

    def test_home_page_loads(self, client):
        """Test that home page loads successfully."""
        response = client.get('/')
        assert response.status_code == 200
        assert b'Welcome to Django' in response.content

    def test_about_page_loads(self, client):
        """Test that about page loads successfully."""
        response = client.get('/about/')
        assert response.status_code == 200
        assert b'About This Django Template' in response.content

    def test_dashboard_page_loads(self, client):
        """Test that dashboard page loads successfully."""
        response = client.get('/dashboard/')
        assert response.status_code == 200
        assert b'Dashboard' in response.content

    def test_health_check_json_response(self, client):
        """Test that health check returns JSON."""
        response = client.get('/health/')
        assert response.status_code == 200
        assert response['Content-Type'] == 'application/json'
        
    def test_config_json_response(self, client):
        """Test that config endpoint returns JSON."""
        response = client.get('/config/')
        assert response.status_code == 200
        assert response['Content-Type'] == 'application/json' 