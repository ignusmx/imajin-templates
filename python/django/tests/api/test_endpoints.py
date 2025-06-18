"""
Tests for API endpoints.
"""

import json
import pytest
from django.urls import reverse
from django.test import TestCase


class APIEndpointsTestCase(TestCase):
    """Test cases for API endpoints."""

    def test_api_status_endpoint(self):
        """Test API status endpoint."""
        response = self.client.get(reverse('api:status'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')
        
        data = json.loads(response.content)
        self.assertIn('status', data)
        self.assertIn('version', data)
        self.assertIn('timestamp', data)

    def test_api_health_endpoint(self):
        """Test API health check endpoint."""
        response = self.client.get(reverse('api:health'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')
        
        data = json.loads(response.content)
        self.assertIn('status', data)
        self.assertIn('checks', data)

    def test_api_stats_endpoint(self):
        """Test API stats endpoint."""
        response = self.client.get(reverse('api:stats'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')
        
        data = json.loads(response.content)
        self.assertIn('users', data)
        self.assertIn('requests', data)

    def test_api_items_list_endpoint(self):
        """Test API items list endpoint."""
        response = self.client.get(reverse('api:items-list'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')
        
        data = json.loads(response.content)
        self.assertIn('items', data)
        self.assertIn('pagination', data)

    def test_api_items_create_endpoint(self):
        """Test API items create endpoint."""
        item_data = {
            'name': 'Test Item',
            'description': 'A test item',
            'status': 'active'
        }
        
        response = self.client.post(
            reverse('api:items-create'),
            data=json.dumps(item_data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response['Content-Type'], 'application/json')
        
        data = json.loads(response.content)
        self.assertIn('id', data)
        self.assertEqual(data['name'], 'Test Item')

    def test_api_webhook_endpoint(self):
        """Test API webhook endpoint."""
        webhook_data = {
            'event': 'test.event',
            'data': {'key': 'value'}
        }
        
        response = self.client.post(
            reverse('api:webhook'),
            data=json.dumps(webhook_data),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response['Content-Type'], 'application/json')
        
        data = json.loads(response.content)
        self.assertIn('received', data)
        self.assertTrue(data['received'])


@pytest.mark.django_db
class TestAPIEndpoints:
    """Pytest-style tests for API endpoints."""

    def test_status_endpoint_returns_json(self, api_client):
        """Test that status endpoint returns valid JSON."""
        response = api_client.get('/api/v1/status/')
        assert response.status_code == 200
        assert response['Content-Type'] == 'application/json'
        
        data = response.json()
        assert 'status' in data
        assert 'version' in data
        assert data['status'] == 'ok'

    def test_health_endpoint_returns_checks(self, api_client):
        """Test that health endpoint returns system checks."""
        response = api_client.get('/api/v1/health/')
        assert response.status_code == 200
        
        data = response.json()
        assert 'status' in data
        assert 'checks' in data
        assert isinstance(data['checks'], dict)

    def test_stats_endpoint_returns_metrics(self, api_client):
        """Test that stats endpoint returns metrics."""
        response = api_client.get('/api/v1/stats/')
        assert response.status_code == 200
        
        data = response.json()
        assert 'users' in data
        assert 'requests' in data
        assert isinstance(data['users'], int)

    def test_items_list_endpoint_pagination(self, api_client):
        """Test that items list endpoint returns paginated data."""
        response = api_client.get('/api/v1/items/')
        assert response.status_code == 200
        
        data = response.json()
        assert 'items' in data
        assert 'pagination' in data
        assert isinstance(data['items'], list)

    def test_items_create_endpoint_validation(self, api_client):
        """Test that items create endpoint validates input."""
        # Test with invalid data
        response = api_client.post('/api/v1/items/create/', {})
        assert response.status_code == 400
        
        # Test with valid data
        valid_data = {
            'name': 'Test Item',
            'description': 'Test description',
            'status': 'active'
        }
        response = api_client.post('/api/v1/items/create/', valid_data)
        assert response.status_code == 201
        
        data = response.json()
        assert data['name'] == 'Test Item'

    def test_webhook_endpoint_processes_data(self, api_client):
        """Test that webhook endpoint processes incoming data."""
        webhook_data = {
            'event': 'user.created',
            'data': {
                'user_id': 123,
                'email': 'test@example.com'
            }
        }
        
        response = api_client.post('/api/v1/webhook/', webhook_data)
        assert response.status_code == 200
        
        data = response.json()
        assert data['received'] is True
        assert 'event' in data
        assert data['event'] == 'user.created' 