#!/bin/bash
set -e

echo "🚀 Starting Rails development environment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️ .env file not found. Running setup first..."
    ./scripts/setup.sh
fi

# Start all services
echo "🐳 Starting Docker services..."
docker compose up --build

echo "🎉 Development environment started!"
echo "🌐 Application available at: http://localhost:3000"
echo "🗄️ Database available at: localhost:5432"
echo "🔴 Redis available at: localhost:6379"
echo ""
echo "📝 Useful commands:"
echo "   docker-compose logs -f app    # View app logs"
echo "   docker-compose exec app bash  # Access app container"
echo "   docker-compose down           # Stop all services" 