<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ApiController extends Controller
{
    /**
     * API status endpoint.
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'message' => 'Laravel API is running!',
            'timestamp' => now()->toISOString(),
            'version' => '1.0.0',
            'environment' => app()->environment(),
            'uptime' => $this->getUptime(),
        ]);
    }

    /**
     * Health check endpoint for monitoring.
     */
    public function health(): JsonResponse
    {
        $checks = [
            'database' => $this->checkDatabase(),
            'cache' => $this->checkCache(),
            'storage' => $this->checkStorage(),
        ];

        $isHealthy = collect($checks)->every(fn($check) => $check['status'] === 'ok');

        return response()->json([
            'status' => $isHealthy ? 'healthy' : 'unhealthy',
            'checks' => $checks,
            'timestamp' => now()->toISOString(),
        ], $isHealthy ? 200 : 503);
    }

    /**
     * Get application statistics.
     */
    public function stats(): JsonResponse
    {
        $stats = Cache::remember('app.stats', 300, function () {
            return [
                'users_count' => 1250,
                'active_users' => 340,
                'total_requests' => 45678,
                'avg_response_time' => '120ms',
                'error_rate' => '0.1%',
                'uptime_percentage' => '99.9%',
                'last_deployment' => now()->subDays(3)->toISOString(),
                'memory_usage' => $this->getMemoryUsage(),
                'disk_usage' => $this->getDiskUsage(),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $stats,
            'cached_at' => Cache::get('app.stats.timestamp', now()->toISOString()),
        ]);
    }

    /**
     * Sample CRUD endpoint - Get all items.
     */
    public function items(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'page' => 'integer|min:1',
            'per_page' => 'integer|min:1|max:100',
            'search' => 'string|max:255',
            'sort' => 'string|in:name,created_at,updated_at',
            'order' => 'string|in:asc,desc',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $page = $request->get('page', 1);
        $perPage = $request->get('per_page', 15);
        $search = $request->get('search');
        $sort = $request->get('sort', 'created_at');
        $order = $request->get('order', 'desc');

        // Sample data
        $items = collect([
            ['id' => 1, 'name' => 'Laravel Application', 'status' => 'active', 'created_at' => now()->subDays(10)],
            ['id' => 2, 'name' => 'Docker Container', 'status' => 'running', 'created_at' => now()->subDays(5)],
            ['id' => 3, 'name' => 'PostgreSQL Database', 'status' => 'connected', 'created_at' => now()->subDays(3)],
            ['id' => 4, 'name' => 'Redis Cache', 'status' => 'active', 'created_at' => now()->subDays(1)],
            ['id' => 5, 'name' => 'API Endpoints', 'status' => 'operational', 'created_at' => now()],
        ]);

        // Apply search filter
        if ($search) {
            $items = $items->filter(function ($item) use ($search) {
                return stripos($item['name'], $search) !== false;
            });
        }

        // Apply sorting
        $items = $items->sortBy($sort, SORT_REGULAR, $order === 'desc');

        // Simulate pagination
        $total = $items->count();
        $items = $items->forPage($page, $perPage)->values();

        return response()->json([
            'status' => 'success',
            'data' => $items,
            'meta' => [
                'current_page' => $page,
                'per_page' => $perPage,
                'total' => $total,
                'last_page' => ceil($total / $perPage),
            ],
        ]);
    }

    /**
     * Sample POST endpoint - Create new item.
     */
    public function createItem(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'status' => 'required|in:active,inactive,pending',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $item = [
            'id' => rand(1000, 9999),
            'name' => $request->get('name'),
            'description' => $request->get('description'),
            'status' => $request->get('status'),
            'created_at' => now()->toISOString(),
            'updated_at' => now()->toISOString(),
        ];

        return response()->json([
            'status' => 'success',
            'message' => 'Item created successfully',
            'data' => $item,
        ], 201);
    }

    /**
     * Check database connectivity.
     */
    private function checkDatabase(): array
    {
        try {
            DB::connection()->getPdo();
            return ['status' => 'ok', 'message' => 'Database connection successful'];
        } catch (\Exception $e) {
            return ['status' => 'error', 'message' => 'Database connection failed: ' . $e->getMessage()];
        }
    }

    /**
     * Check cache connectivity.
     */
    private function checkCache(): array
    {
        try {
            Cache::put('health_check', 'ok', 10);
            $value = Cache::get('health_check');
            return $value === 'ok' 
                ? ['status' => 'ok', 'message' => 'Cache is working']
                : ['status' => 'error', 'message' => 'Cache read/write failed'];
        } catch (\Exception $e) {
            return ['status' => 'error', 'message' => 'Cache error: ' . $e->getMessage()];
        }
    }

    /**
     * Check storage accessibility.
     */
    private function checkStorage(): array
    {
        try {
            $testFile = storage_path('logs/health_check.tmp');
            file_put_contents($testFile, 'test');
            $content = file_get_contents($testFile);
            unlink($testFile);
            
            return $content === 'test'
                ? ['status' => 'ok', 'message' => 'Storage is writable']
                : ['status' => 'error', 'message' => 'Storage read/write failed'];
        } catch (\Exception $e) {
            return ['status' => 'error', 'message' => 'Storage error: ' . $e->getMessage()];
        }
    }

    /**
     * Get application uptime.
     */
    private function getUptime(): string
    {
        return now()->subDays(30)->diffForHumans();
    }

    /**
     * Get memory usage information.
     */
    private function getMemoryUsage(): array
    {
        return [
            'current' => round(memory_get_usage(true) / 1024 / 1024, 2) . ' MB',
            'peak' => round(memory_get_peak_usage(true) / 1024 / 1024, 2) . ' MB',
            'limit' => ini_get('memory_limit'),
        ];
    }

    /**
     * Get disk usage information.
     */
    private function getDiskUsage(): array
    {
        $bytes = disk_free_space('/');
        $total = disk_total_space('/');
        
        return [
            'free' => round($bytes / 1024 / 1024 / 1024, 2) . ' GB',
            'total' => round($total / 1024 / 1024 / 1024, 2) . ' GB',
            'used_percentage' => round((($total - $bytes) / $total) * 100, 2) . '%',
        ];
    }
} 