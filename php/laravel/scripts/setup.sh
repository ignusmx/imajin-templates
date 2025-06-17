#!/bin/bash

set -e

echo "🚀 Setting up Laravel Development Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Check if Docker Compose is available
check_docker_compose() {
    print_status "Checking Docker Compose..."
    
    if docker compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
    elif docker-compose --version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
    else
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    
    print_success "Docker Compose is available"
}

# Create .env file from .env.example if it doesn't exist
setup_env_file() {
    print_status "Setting up environment file..."
    
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            print_success "Created .env file from .env.example"
        else
            print_warning ".env.example not found, creating basic .env file"
            cat > .env << EOF
APP_NAME="Laravel App"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:3000

DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=laravel_development
DB_USERNAME=postgres
DB_PASSWORD=password

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
EOF
        fi
    else
        print_success ".env file already exists"
    fi
}

# Generate Laravel application key
generate_app_key() {
    print_status "Generating Laravel application key..."
    
    # Check if APP_KEY is empty in .env
    if ! grep -q "APP_KEY=base64:" .env; then
        # Generate a new key using PHP
        APP_KEY=$(php -r "echo 'base64:' . base64_encode(random_bytes(32));")
        
        # Update .env file
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|APP_KEY=.*|APP_KEY=${APP_KEY}|" .env
        else
            # Linux
            sed -i "s|APP_KEY=.*|APP_KEY=${APP_KEY}|" .env
        fi
        
        print_success "Laravel application key generated"
    else
        print_success "Laravel application key already exists"
    fi
}

# Create Laravel project if it doesn't exist
create_laravel_project() {
    print_status "Checking Laravel project structure..."
    
    if [ ! -f "artisan" ] && [ ! -f "composer.json" ]; then
        print_status "Creating new Laravel project..."
        
        # Create basic Laravel structure
        mkdir -p app/{Console,Exceptions,Http/{Controllers,Middleware},Models,Providers}
        mkdir -p bootstrap/{cache,providers}
        mkdir -p config
        mkdir -p database/{factories,migrations,seeders}
        mkdir -p public
        mkdir -p resources/{css,js,views}
        mkdir -p routes
        mkdir -p storage/{app/{public,private},framework/{cache,sessions,views},logs}
        mkdir -p tests/{Feature,Unit}
        
        # Create basic composer.json
        cat > composer.json << 'EOF'
{
    "name": "laravel/laravel",
    "type": "project",
    "description": "The Laravel Framework.",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "require": {
        "php": "^8.2",
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/tinker": "^2.9"
    },
    "require-dev": {
        "fakerphp/faker": "^1.23",
        "laravel/pint": "^1.13",
        "laravel/sail": "^1.26",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.0",
        "phpunit/phpunit": "^11.0",
        "spatie/laravel-ignition": "^2.4"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi",
            "@php -r \"file_exists('database/database.sqlite') || touch('database/database.sqlite');\"",
            "@php artisan migrate --graceful --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

        # Create basic package.json
        cat > package.json << 'EOF'
{
    "private": true,
    "type": "module",
    "scripts": {
        "build": "vite build",
        "dev": "vite"
    },
    "devDependencies": {
        "@vitejs/plugin-laravel": "^1.0",
        "axios": "^1.6.4",
        "laravel-vite-plugin": "^1.0",
        "vite": "^5.0"
    }
}
EOF

        print_success "Basic Laravel project structure created"
    else
        print_success "Laravel project structure exists"
    fi
}

# Build and start containers
start_containers() {
    print_status "Building and starting Docker containers..."
    
    $DOCKER_COMPOSE_CMD down -v 2>/dev/null || true
    $DOCKER_COMPOSE_CMD build --no-cache
    $DOCKER_COMPOSE_CMD up -d --remove-orphans
    
    print_success "Docker containers started"
}

# Wait for database to be ready
wait_for_database() {
    print_status "Waiting for database to be ready..."
    
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if $DOCKER_COMPOSE_CMD exec -T db pg_isready -U postgres > /dev/null 2>&1; then
            print_success "Database is ready"
            return 0
        fi
        
        print_status "Waiting for database... (attempt $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_error "Database failed to start within expected time"
    return 1
}

# Install dependencies and run Laravel setup
setup_laravel() {
    print_status "Installing Composer dependencies..."
    $DOCKER_COMPOSE_CMD exec -T app composer install --no-interaction --prefer-dist --optimize-autoloader
    
    print_status "Installing Node.js dependencies..."
    $DOCKER_COMPOSE_CMD exec -T app npm install
    
    print_status "Generating Laravel application key..."
    $DOCKER_COMPOSE_CMD exec -T app php artisan key:generate --no-interaction
    
    print_status "Running database migrations..."
    $DOCKER_COMPOSE_CMD exec -T app php artisan migrate --no-interaction --force
    
    print_status "Clearing and caching configuration..."
    $DOCKER_COMPOSE_CMD exec -T app php artisan config:clear
    $DOCKER_COMPOSE_CMD exec -T app php artisan cache:clear
    $DOCKER_COMPOSE_CMD exec -T app php artisan route:clear
    $DOCKER_COMPOSE_CMD exec -T app php artisan view:clear
    
    print_success "Laravel setup completed"
}

# Create storage symlink
create_storage_link() {
    print_status "Creating storage symlink..."
    $DOCKER_COMPOSE_CMD exec -T app php artisan storage:link 2>/dev/null || true
    print_success "Storage symlink created"
}

# Set proper permissions
set_permissions() {
    print_status "Setting proper permissions..."
    $DOCKER_COMPOSE_CMD exec -T app chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
    $DOCKER_COMPOSE_CMD exec -T app chmod -R 775 /var/www/storage /var/www/bootstrap/cache
    print_success "Permissions set"
}

# Show final status
show_status() {
    echo ""
    echo "=================================="
    print_success "🎉 Laravel Development Environment Setup Complete!"
    echo "=================================="
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Run: ./scripts/dev.sh"
    echo "   2. Open: http://localhost:3000"
    echo ""
    echo "🛠️  Available Commands:"
    echo "   • Start development: ./scripts/dev.sh"
    echo "   • Run tests: ./scripts/test.sh"
    echo "   • Access container: docker compose exec app bash"
    echo "   • View logs: docker compose logs -f app"
    echo ""
    echo "🔗 Services:"
    echo "   • Application: http://localhost:3000"
    echo "   • Database: localhost:5432 (postgres/password)"
    echo "   • Redis: localhost:6379"
    echo ""
}

# Main execution
main() {
    echo "🚀 Laravel Development Environment Setup"
    echo "========================================"
    echo ""
    
    check_docker
    check_docker_compose
    setup_env_file
    generate_app_key
    create_laravel_project
    start_containers
    wait_for_database
    setup_laravel
    create_storage_link
    set_permissions
    show_status
}

# Run main function
main "$@" 