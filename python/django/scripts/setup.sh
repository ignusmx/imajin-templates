#!/bin/bash

set -e

echo "🚀 Setting up Django Development Environment..."

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

# Create .env file from env.example if it doesn't exist
setup_env_file() {
    print_status "Setting up environment file..."
    
    if [ ! -f .env ]; then
        if [ -f env.example ]; then
            cp env.example .env
            print_success "Created .env file from env.example"
        else
            print_warning "env.example not found, creating basic .env file"
            cat > .env << EOF
# Django Settings
DJANGO_SETTINGS_MODULE=config.settings.local
SECRET_KEY=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# Database
DATABASE_URL=postgresql://postgres:password@db:5432/django_development
DB_NAME=django_development
DB_USER=postgres
DB_PASSWORD=password
DB_HOST=db
DB_PORT=5432

# Redis
REDIS_URL=redis://redis:6379/0

# Celery
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0
EOF
        fi
    else
        print_success ".env file already exists"
    fi
}

# Generate Django secret key
generate_secret_key() {
    print_status "Generating Django secret key..."
    
    # Check if SECRET_KEY is empty in .env
    if ! grep -q "SECRET_KEY=.*[^[:space:]]" .env; then
        # Generate a new secret key using Python
        SECRET_KEY=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
        
        # Update .env file
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|SECRET_KEY=.*|SECRET_KEY=${SECRET_KEY}|" .env
        else
            # Linux
            sed -i "s|SECRET_KEY=.*|SECRET_KEY=${SECRET_KEY}|" .env
        fi
        
        print_success "Django secret key generated"
    else
        print_success "Django secret key already exists"
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

# Install dependencies and run Django setup
setup_django() {
    print_status "Installing Python dependencies..."
    $DOCKER_COMPOSE_CMD exec -T app uv sync --dev
    
    print_status "Installing Node.js dependencies..."
    $DOCKER_COMPOSE_CMD exec -T app npm install
    
    print_status "Building Tailwind CSS..."
    $DOCKER_COMPOSE_CMD exec -T app npm run build
    
    print_status "Running database migrations..."
    $DOCKER_COMPOSE_CMD exec -T app uv run python manage.py migrate --no-input
    
    print_status "Collecting static files..."
    $DOCKER_COMPOSE_CMD exec -T app uv run python manage.py collectstatic --no-input
    
    print_success "Django setup completed"
}

# Create superuser
create_superuser() {
    print_status "Creating Django superuser..."
    
    $DOCKER_COMPOSE_CMD exec -T app uv run python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created: admin/admin123')
else:
    print('Superuser already exists')
"
    
    print_success "Superuser setup completed"
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p logs
    mkdir -p staticfiles
    mkdir -p mediafiles
    mkdir -p database/init
    
    print_success "Directories created"
}

# Show final status
show_status() {
    echo ""
    echo "=================================="
    print_success "🎉 Django Development Environment Setup Complete!"
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
    echo "   • Admin: http://localhost:3000/admin (admin/admin123)"
    echo "   • Database: localhost:5433 (postgres/password)"
    echo "   • Redis: localhost:6380"
    echo ""
}

# Main execution
main() {
    echo "🚀 Django Development Environment Setup"
    echo "======================================="
    echo ""
    
    check_docker
    check_docker_compose
    create_directories
    setup_env_file
    generate_secret_key
    start_containers
    wait_for_database
    setup_django
    create_superuser
    show_status
}

# Run main function
main "$@" 