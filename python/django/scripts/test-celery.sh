#!/bin/bash

# Test Celery functionality script
set -e

echo "🧪 Testing Celery functionality..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if containers are running
print_status "Checking container status..."
if ! docker-compose ps | grep -q "Up"; then
    print_error "Containers are not running. Please run 'docker-compose up -d' first."
    exit 1
fi

# Test Redis connection
print_status "Testing Redis connection..."
if docker-compose exec -T redis redis-cli ping | grep -q "PONG"; then
    print_status "✅ Redis is responding"
else
    print_error "❌ Redis is not responding"
    exit 1
fi

# Test PostgreSQL connection
print_status "Testing PostgreSQL connection..."
if docker-compose exec -T db pg_isready -U postgres | grep -q "accepting connections"; then
    print_status "✅ PostgreSQL is accepting connections"
else
    print_error "❌ PostgreSQL is not accepting connections"
    exit 1
fi

# Test Django app health
print_status "Testing Django app health..."
if curl -f -s http://localhost:3000/health/ > /dev/null; then
    print_status "✅ Django app is healthy"
else
    print_error "❌ Django app health check failed"
    exit 1
fi

# Test Celery worker
print_status "Testing Celery worker..."
if docker-compose exec -T celery uv run celery -A config inspect ping | grep -q "pong"; then
    print_status "✅ Celery worker is responding"
else
    print_error "❌ Celery worker is not responding"
    print_warning "Checking Celery worker logs..."
    docker-compose logs --tail=20 celery
    exit 1
fi

# Test Celery beat
print_status "Testing Celery beat..."
if docker-compose ps celery-beat | grep -q "Up"; then
    print_status "✅ Celery beat is running"
else
    print_error "❌ Celery beat is not running"
    print_warning "Checking Celery beat logs..."
    docker-compose logs --tail=20 celery-beat
fi

# Test task execution via Django endpoint
print_status "Testing task execution via Django..."
response=$(curl -s -X POST http://localhost:3000/test-celery/)
if echo "$response" | grep -q "success"; then
    print_status "✅ Celery tasks executed successfully"
    echo "$response" | python -m json.tool
else
    print_error "❌ Celery task execution failed"
    echo "Response: $response"
fi

print_status "🎉 Celery test completed!"

# Show active tasks
print_status "Active tasks:"
docker-compose exec -T celery uv run celery -A config inspect active || true

# Show registered tasks
print_status "Registered tasks:"
docker-compose exec -T celery uv run celery -A config inspect registered || true 