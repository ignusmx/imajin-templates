<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiTest extends TestCase
{
    /**
     * Test API status endpoint.
     */
    public function test_api_status_endpoint(): void
    {
        $response = $this->get('/api/v1/status');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'success',
                     'message' => 'Laravel API is running!',
                 ])
                 ->assertJsonStructure([
                     'status',
                     'message',
                     'timestamp',
                     'version',
                     'environment',
                     'uptime',
                 ]);
    }

    /**
     * Test API health check endpoint.
     */
    public function test_api_health_endpoint(): void
    {
        $response = $this->get('/api/v1/health');

        $response->assertSuccessful()
                 ->assertJsonStructure([
                     'status',
                     'checks' => [
                         'database' => ['status', 'message'],
                         'cache' => ['status', 'message'],
                         'storage' => ['status', 'message'],
                     ],
                     'timestamp',
                 ]);
    }

    /**
     * Test API stats endpoint.
     */
    public function test_api_stats_endpoint(): void
    {
        $response = $this->get('/api/v1/stats');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'status',
                     'data' => [
                         'users_count',
                         'active_users',
                         'total_requests',
                         'avg_response_time',
                         'error_rate',
                         'uptime_percentage',
                         'last_deployment',
                         'memory_usage',
                         'disk_usage',
                     ],
                     'cached_at',
                 ]);
    }

    /**
     * Test API items list endpoint.
     */
    public function test_api_items_list(): void
    {
        $response = $this->get('/api/v1/items');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'status',
                     'data' => [
                         '*' => ['id', 'name', 'status', 'created_at']
                     ],
                     'meta' => [
                         'current_page',
                         'per_page',
                         'total',
                         'last_page',
                     ],
                 ]);
    }

    /**
     * Test API items list with pagination.
     */
    public function test_api_items_pagination(): void
    {
        $response = $this->get('/api/v1/items?page=1&per_page=2');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'success',
                     'meta' => [
                         'current_page' => 1,
                         'per_page' => 2,
                     ],
                 ]);
    }

    /**
     * Test API items list with search.
     */
    public function test_api_items_search(): void
    {
        $response = $this->get('/api/v1/items?search=Laravel');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'success',
                 ]);

        $data = $response->json('data');
        $this->assertTrue(
            collect($data)->every(function ($item) {
                return stripos($item['name'], 'Laravel') !== false;
            })
        );
    }

    /**
     * Test API item creation.
     */
    public function test_api_create_item(): void
    {
        $itemData = [
            'name' => 'Test Item',
            'description' => 'This is a test item',
            'status' => 'active',
        ];

        $response = $this->post('/api/v1/items', $itemData);

        $response->assertStatus(201)
                 ->assertJson([
                     'status' => 'success',
                     'message' => 'Item created successfully',
                 ])
                 ->assertJsonStructure([
                     'status',
                     'message',
                     'data' => [
                         'id',
                         'name',
                         'description',
                         'status',
                         'created_at',
                         'updated_at',
                     ],
                 ]);

        $this->assertEquals($itemData['name'], $response->json('data.name'));
        $this->assertEquals($itemData['description'], $response->json('data.description'));
        $this->assertEquals($itemData['status'], $response->json('data.status'));
    }

    /**
     * Test API item creation validation.
     */
    public function test_api_create_item_validation(): void
    {
        $response = $this->post('/api/v1/items', []);

        $response->assertStatus(422)
                 ->assertJson([
                     'status' => 'error',
                     'message' => 'Validation failed',
                 ])
                 ->assertJsonValidationErrors(['name', 'status']);
    }

    /**
     * Test API item creation with invalid status.
     */
    public function test_api_create_item_invalid_status(): void
    {
        $itemData = [
            'name' => 'Test Item',
            'status' => 'invalid_status',
        ];

        $response = $this->post('/api/v1/items', $itemData);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['status']);
    }

    /**
     * Test API webhook endpoint.
     */
    public function test_api_webhook(): void
    {
        $webhookData = [
            'event' => 'test',
            'data' => ['message' => 'Hello webhook!'],
        ];

        $response = $this->post('/api/v1/webhook', $webhookData);

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'success',
                     'message' => 'Webhook received',
                 ])
                 ->assertJsonStructure([
                     'status',
                     'message',
                     'received_at',
                 ]);
    }

    /**
     * Test API fallback for non-existent endpoints.
     */
    public function test_api_fallback(): void
    {
        $response = $this->get('/api/non-existent-endpoint');

        $response->assertStatus(404)
                 ->assertJson([
                     'status' => 'error',
                     'message' => 'API endpoint not found',
                 ]);
    }

    /**
     * Test API CORS headers.
     */
    public function test_api_cors_headers(): void
    {
        $response = $this->get('/api/v1/status');

        $response->assertStatus(200);
        
        // In a real application, you'd test for actual CORS headers
        // This is just an example of how you might test headers
        $this->assertNotNull($response->headers->get('content-type'));
    }
} 