# Development Guide

This guide covers advanced development workflows and best practices for the Laravel Docker template.

## 🏗️ Development Environment

### **Docker Architecture**

The development environment consists of:

- **App Container**: Laravel application with PHP 8.3, Xdebug, and development tools
- **Database Container**: PostgreSQL 16 with persistent data
- **Redis Container**: Redis 7 for caching and sessions
- **Queue Container**: Background job processing
- **Scheduler Container**: Laravel task scheduling

### **Volume Mounts**

- `./:/var/www` - Live code reloading
- `vendor_cache:/var/www/vendor` - Composer dependency cache
- `node_modules_cache:/var/www/node_modules` - NPM dependency cache
- `postgres_data` - Database persistence
- `redis_data` - Redis persistence

## 🔧 Development Workflow

### **Starting Development**

```bash
# First time setup
./scripts/setup.sh

# Daily development
./scripts/dev.sh

# View logs
docker compose logs -f app
```

### **Code Changes**

Code changes are automatically reflected due to volume mounts:

1. Edit files in your IDE
2. Changes are immediately available in the container
3. Laravel's built-in development server handles auto-reloading
4. Assets are compiled on-demand with Vite

### **Database Development**

```bash
# Create migration
docker compose exec app php artisan make:migration create_products_table

# Run migrations
docker compose exec app php artisan migrate

# Rollback migrations
docker compose exec app php artisan migrate:rollback

# Reset database
docker compose exec app php artisan migrate:fresh --seed

# Create seeder
docker compose exec app php artisan make:seeder ProductSeeder
```

### **Model Development**

```bash
# Create model with migration and factory
docker compose exec app php artisan make:model Product -mf

# Create controller
docker compose exec app php artisan make:controller ProductController --resource

# Create request
docker compose exec app php artisan make:request StoreProductRequest
```

## 🧪 Testing Workflow

### **Test-Driven Development**

```bash
# Create test
docker compose exec app php artisan make:test ProductTest

# Run specific test
docker compose exec app php artisan test --filter ProductTest

# Run tests with coverage
./scripts/test.sh --coverage
```

### **Test Database**

The test environment uses a separate database:

```bash
# Create test database
docker compose exec db createdb -U postgres laravel_testing

# Run migrations for testing
docker compose exec app php artisan migrate --env=testing
```

## 🔍 Debugging

### **Xdebug Configuration**

Xdebug is pre-configured for step debugging:

1. **VS Code**: Install PHP Debug extension
2. **PHPStorm**: Configure remote debugging
3. **Breakpoints**: Set in your IDE
4. **Debug URL**: http://localhost:3000

### **Debug Configuration**

```json
// .vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www": "${workspaceFolder}"
            }
        }
    ]
}
```

### **Logging**

```bash
# View application logs
docker compose logs -f app

# View Laravel logs
tail -f storage/logs/laravel.log

# View database logs
docker compose logs -f db

# View Redis logs
docker compose logs -f redis
```

## 📦 Package Management

### **Composer Dependencies**

```bash
# Install package
docker compose exec app composer require vendor/package

# Install dev dependency
docker compose exec app composer require --dev vendor/package

# Update dependencies
docker compose exec app composer update

# Autoload optimization
docker compose exec app composer dump-autoload -o
```

### **NPM Dependencies**

```bash
# Install package
docker compose exec app npm install package-name

# Install dev dependency
docker compose exec app npm install --save-dev package-name

# Update dependencies
docker compose exec app npm update

# Build assets
docker compose exec app npm run build
```

## 🎨 Frontend Development

### **Vite Configuration**

```javascript
// vite.config.js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    server: {
        hmr: {
            host: 'localhost',
        },
    },
});
```

### **Asset Compilation**

```bash
# Development build
docker compose exec app npm run dev

# Production build
docker compose exec app npm run build

# Watch for changes
docker compose exec app npm run dev -- --watch
```

## 📊 Performance Optimization

### **Development Performance**

```bash
# Cache routes
docker compose exec app php artisan route:cache

# Cache config
docker compose exec app php artisan config:cache

# Cache views
docker compose exec app php artisan view:cache

# Clear all caches
docker compose exec app php artisan optimize:clear
```

### **Database Performance**

```bash
# Generate IDE helper
docker compose exec app composer require --dev barryvdh/laravel-ide-helper
docker compose exec app php artisan ide-helper:generate

# Database optimization
docker compose exec app php artisan optimize:clear
docker compose exec app php artisan config:cache
```

## 🔒 Security

### **Development Security**

```bash
# Security audit
docker compose exec app composer audit

# Check for vulnerabilities
docker compose exec app composer require --dev enlightn/enlightn
docker compose exec app php artisan enlightn
```

### **Environment Security**

- Never commit `.env` files
- Use strong database passwords
- Keep dependencies updated
- Run security audits regularly

## 🚀 Advanced Features

### **Queue Development**

```bash
# Create job
docker compose exec app php artisan make:job ProcessOrder

# Process queue
docker compose exec app php artisan queue:work

# Monitor queue
docker compose exec app php artisan queue:monitor
```

### **Scheduled Tasks**

```bash
# Define in app/Console/Kernel.php
protected function schedule(Schedule $schedule)
{
    $schedule->command('inspire')->hourly();
}

# Test scheduler
docker compose exec app php artisan schedule:run
```

### **Broadcasting**

```bash
# Install Pusher
docker compose exec app composer require pusher/pusher-php-server

# Configure broadcasting
docker compose exec app php artisan make:event OrderShipped
```

## 🛠️ Troubleshooting

### **Common Development Issues**

**Container Permission Issues:**
```bash
# Fix permissions
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
docker compose exec app chmod -R 775 storage bootstrap/cache
```

**Database Connection Issues:**
```bash
# Check database status
docker compose exec db pg_isready -U postgres

# Restart database
docker compose restart db
```

**Memory Issues:**
```bash
# Increase PHP memory limit
echo "memory_limit = 512M" >> php.ini

# Monitor memory usage
docker stats
```

## 📚 Best Practices

### **Code Organization**

- Use Service classes for business logic
- Keep Controllers thin
- Use Form Requests for validation
- Implement Repository pattern for complex queries
- Use Eloquent Resources for API responses

### **Database Best Practices**

- Always use migrations
- Use database seeders for test data
- Index frequently queried columns
- Use soft deletes when appropriate
- Implement proper foreign key constraints

### **Testing Best Practices**

- Write tests for all features
- Use factories for test data
- Mock external services
- Test edge cases and error conditions
- Maintain high test coverage

---

Happy developing! 🚀 