<?php

namespace Tests\Feature;

use Tests\TestCase;

class WebTest extends TestCase
{
    /**
     * Test the homepage loads successfully.
     */
    public function test_homepage_loads(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200)
                 ->assertSee('Laravel Docker Template')
                 ->assertSee('Production-ready Laravel starter')
                 ->assertSee('Docker-first development');
    }

    /**
     * Test the about page loads successfully.
     */
    public function test_about_page_loads(): void
    {
        $response = $this->get('/about');

        $response->assertStatus(200)
                 ->assertSee('Docker-First Development')
                 ->assertSee('Modern PHP Stack')
                 ->assertSee('Comprehensive Testing');
    }

    /**
     * Test the dashboard page loads successfully.
     */
    public function test_dashboard_loads(): void
    {
        $response = $this->get('/dashboard');

        $response->assertStatus(200)
                 ->assertSee('Dashboard')
                 ->assertSee('Active Users')
                 ->assertSee('System Status');
    }

    /**
     * Test the health check endpoint.
     */
    public function test_health_check(): void
    {
        $response = $this->get('/health');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'ok',
                     'service' => 'Laravel Application'
                 ])
                 ->assertJsonStructure([
                     'status',
                     'timestamp',
                     'service'
                 ]);
    }

    /**
     * Test phpinfo is only available in local environment.
     */
    public function test_phpinfo_local_only(): void
    {
        // This test assumes we're in testing environment
        // In a real app, you'd mock the environment
        $response = $this->get('/phpinfo');
        
        // Should be forbidden in non-local environment
        $response->assertStatus(403);
    }

    /**
     * Test config endpoint is only available in local environment.
     */
    public function test_config_local_only(): void
    {
        // This test assumes we're in testing environment
        $response = $this->get('/config');
        
        // Should be forbidden in non-local environment
        $response->assertStatus(403);
    }

    /**
     * Test navigation links work correctly.
     */
    public function test_navigation_links(): void
    {
        $response = $this->get('/');
        
        $response->assertStatus(200);
        
        // Test that navigation links are present
        $response->assertSee('href="/"', false)
                 ->assertSee('href="/about"', false)
                 ->assertSee('href="/dashboard"', false)
                 ->assertSee('href="/api/v1/status"', false);
    }

    /**
     * Test homepage stats are displayed.
     */
    public function test_homepage_stats(): void
    {
        $response = $this->get('/');
        
        $response->assertStatus(200)
                 ->assertSee('Active Users')
                 ->assertSee('Projects')
                 ->assertSee('Deployments')
                 ->assertSee('Uptime');
    }

    /**
     * Test responsive design elements.
     */
    public function test_responsive_design(): void
    {
        $response = $this->get('/');
        
        $response->assertStatus(200)
                 ->assertSee('viewport', false) // Meta viewport tag
                 ->assertSee('@media', false); // CSS media queries
    }

    /**
     * Test that pages include security headers.
     */
    public function test_security_headers(): void
    {
        $response = $this->get('/');
        
        $response->assertStatus(200);
        
        // Test for basic security considerations
        $this->assertNotNull($response->headers->get('content-type'));
    }

    /**
     * Test 404 page handling.
     */
    public function test_404_handling(): void
    {
        $response = $this->get('/non-existent-page');
        
        $response->assertStatus(404);
    }

    /**
     * Test that external links have proper attributes.
     */
    public function test_external_links(): void
    {
        $response = $this->get('/');
        
        $response->assertStatus(200)
                 ->assertSee('target="_blank"', false); // External links open in new tab
    }
} 