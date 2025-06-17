<?php

use App\Http\Controllers\Api\ApiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// API versioning
Route::prefix('v1')->group(function () {
    
    // Public API endpoints
    Route::get('/status', [ApiController::class, 'status'])->name('api.status');
    Route::get('/health', [ApiController::class, 'health'])->name('api.health');
    Route::get('/stats', [ApiController::class, 'stats'])->name('api.stats');
    
    // Sample CRUD endpoints
    Route::get('/items', [ApiController::class, 'items'])->name('api.items.index');
    Route::post('/items', [ApiController::class, 'createItem'])->name('api.items.store');
    
    // User endpoint (sample with middleware)
    Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
        return response()->json([
            'status' => 'success',
            'data' => $request->user(),
        ]);
    })->name('api.user');
    
    // Sample protected endpoints
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/protected', function () {
            return response()->json([
                'status' => 'success',
                'message' => 'This is a protected endpoint',
                'user' => auth()->user(),
                'timestamp' => now()->toISOString(),
            ]);
        })->name('api.protected');
        
        Route::post('/logout', function (Request $request) {
            $request->user()->currentAccessToken()->delete();
            
            return response()->json([
                'status' => 'success',
                'message' => 'Successfully logged out',
            ]);
        })->name('api.logout');
    });
    
    // Sample webhook endpoint
    Route::post('/webhook', function (Request $request) {
        // Log the webhook payload
        \Log::info('Webhook received', $request->all());
        
        return response()->json([
            'status' => 'success',
            'message' => 'Webhook received',
            'received_at' => now()->toISOString(),
        ]);
    })->name('api.webhook');
    
});

// Fallback route for undefined API endpoints
Route::fallback(function () {
    return response()->json([
        'status' => 'error',
        'message' => 'API endpoint not found',
        'documentation' => url('/api/v1/status'),
    ], 404);
}); 