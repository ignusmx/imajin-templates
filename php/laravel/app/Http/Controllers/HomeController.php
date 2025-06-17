<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;

class HomeController extends Controller
{
    /**
     * Display the application landing page.
     */
    public function index(): View
    {
        $stats = [
            'users' => 1250,
            'projects' => 3400,
            'deployments' => 15670,
            'uptime' => '99.9%'
        ];

        return view('welcome', compact('stats'));
    }

    /**
     * Display the application dashboard.
     */
    public function dashboard(): View
    {
        $user = auth()->user();
        
        $recentActivity = [
            'Last login: ' . now()->subHours(2)->diffForHumans(),
            'Project "E-commerce Site" deployed successfully',
            'Database backup completed',
            'SSL certificate renewed'
        ];

        return view('dashboard', compact('user', 'recentActivity'));
    }

    /**
     * Display the about page.
     */
    public function about(): View
    {
        $features = [
            [
                'name' => 'Docker-First Development',
                'description' => 'Complete containerized development environment with hot reload',
                'icon' => '🐳'
            ],
            [
                'name' => 'Modern PHP Stack',
                'description' => 'PHP 8.3, Laravel 11, PostgreSQL, and Redis out of the box',
                'icon' => '🚀'
            ],
            [
                'name' => 'Comprehensive Testing',
                'description' => 'PHPUnit, code coverage, security audits, and performance tests',
                'icon' => '🧪'
            ],
            [
                'name' => 'CI/CD Pipeline',
                'description' => 'GitHub Actions with automated testing and deployment',
                'icon' => '⚡'
            ]
        ];

        return view('about', compact('features'));
    }
} 