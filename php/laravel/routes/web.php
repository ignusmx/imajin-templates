<?php

use App\Http\Controllers\HomeController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

// Home routes
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/about', [HomeController::class, 'about'])->name('about');

// Dashboard (requires authentication in real app)
Route::get('/dashboard', [HomeController::class, 'dashboard'])->name('dashboard');

// Health check route for Docker health checks
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toISOString(),
        'service' => 'Laravel Application'
    ]);
})->name('health');

// Simple info routes
Route::get('/phpinfo', function () {
    return app()->environment('local') 
        ? phpinfo() 
        : abort(403, 'Not available in production');
})->name('phpinfo');

Route::get('/config', function () {
    if (!app()->environment('local')) {
        abort(403, 'Not available in production');
    }
    
    return response()->json([
        'app' => [
            'name' => config('app.name'),
            'env' => config('app.env'),
            'debug' => config('app.debug'),
            'url' => config('app.url'),
            'timezone' => config('app.timezone'),
        ],
        'database' => [
            'connection' => config('database.default'),
            'host' => config('database.connections.pgsql.host'),
            'port' => config('database.connections.pgsql.port'),
            'database' => config('database.connections.pgsql.database'),
        ],
        'cache' => [
            'driver' => config('cache.default'),
            'redis_host' => config('database.redis.default.host'),
            'redis_port' => config('database.redis.default.port'),
        ],
    ]);
})->name('config'); 