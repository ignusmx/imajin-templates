#!/bin/bash

set -e

echo "🚀 Starting Laravel Development Environment..."

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

# Detect Docker Compose command
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif docker-compose --version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    print_error "Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Check if .env file exists
check_env_file() {
    if [ ! -f .env ]; then
        print_warning ".env file not found!"
        print_status "Running setup script first..."
        ./scripts/setup.sh
    fi
}

# Start the development environment
start_dev_environment() {
    print_status "Starting Docker containers..."
    
    # Start all services
    $DOCKER_COMPOSE_CMD up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 5
    
    # Check if database is ready
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if $DOCKER_COMPOSE_CMD exec -T db pg_isready -U postgres > /dev/null 2>&1; then
            print_success "Database is ready"
            break
        fi
        
        print_status "Waiting for database... (attempt $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
        
        if [ $attempt -gt $max_attempts ]; then
            print_error "Database failed to start within expected time"
            exit 1
        fi
    done
    
    # Check if Redis is ready
    if $DOCKER_COMPOSE_CMD exec -T redis redis-cli ping > /dev/null 2>&1; then
        print_success "Redis is ready"
    else
        print_warning "Redis might not be ready yet"
    fi
}

# Run Laravel optimizations
optimize_laravel() {
    print_status "Running Laravel optimizations..."
    
    # Clear all caches
    $DOCKER_COMPOSE_CMD exec -T app php artisan config:clear
    $DOCKER_COMPOSE_CMD exec -T app php artisan cache:clear
    $DOCKER_COMPOSE_CMD exec -T app php artisan route:clear
    $DOCKER_COMPOSE_CMD exec -T app php artisan view:clear
    
    # Run migrations if needed
    $DOCKER_COMPOSE_CMD exec -T app php artisan migrate --no-interaction
    
    print_success "Laravel optimizations completed"
}

# Build frontend assets
build_assets() {
    print_status "Building frontend assets..."
    
    # Install npm dependencies if needed
    if [ ! -d "node_modules" ]; then
        $DOCKER_COMPOSE_CMD exec -T app npm install
    fi
    
    # Build assets for development
    $DOCKER_COMPOSE_CMD exec -T app npm run dev &
    
    print_success "Frontend assets are being built"
}

# Show development information
show_dev_info() {
    echo ""
    echo "=================================="
    print_success "🎉 Laravel Development Environment is Running!"
    echo "=================================="
    echo ""
    echo "🔗 Services:"
    echo "   • Application: http://localhost:3000"
    echo "   • Database: localhost:5432 (postgres/password)"
    echo "   • Redis: localhost:6379"
    echo ""
    echo "🛠️  Useful Commands:"
    echo "   • View logs: docker compose logs -f app"
    echo "   • Access container: docker compose exec app bash"
    echo "   • Run artisan: docker compose exec app php artisan [command]"
    echo "   • Run tests: ./scripts/test.sh"
    echo "   • Stop services: docker compose down"
    echo ""
    echo "📝 Development Tips:"
    echo "   • Code changes are automatically reflected (hot reload)"
    echo "   • Database data persists between restarts"
    echo "   • Check logs if something goes wrong"
    echo ""
}

# Handle cleanup on script exit
cleanup() {
    echo ""
    print_status "Development environment is still running in the background"
    print_status "To stop all services, run: docker compose down"
}

# Set trap for cleanup
trap cleanup EXIT

# Main execution
main() {
    echo "🚀 Laravel Development Environment"
    echo "=================================="
    echo ""
    
    check_env_file
    start_dev_environment
    optimize_laravel
    build_assets
    show_dev_info
    
    # Follow application logs
    print_status "Following application logs (Ctrl+C to exit)..."
    echo ""
    $DOCKER_COMPOSE_CMD logs -f app
}

# Run main function
main "$@" 