#!/bin/bash
set -e

echo "🚀 Starting Sinatra API development environment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️ .env file not found. Running setup first..."
    ./scripts/setup.sh
fi

# Start all services
echo "🐳 Starting Docker services..."
docker compose up --build

echo "🎉 Development environment started!"
echo "🌐 API available at: http://localhost:3000"
echo "🗄️ Database available at: localhost:5432"
echo "🔴 Redis available at: localhost:6379"
echo "📖 API Documentation: http://localhost:3000/docs"
echo ""
echo "📝 Useful commands:"
echo "   docker compose logs -f api      # View API logs"
echo "   docker compose exec api bash    # Access API container"
echo "   docker compose down             # Stop all services" 