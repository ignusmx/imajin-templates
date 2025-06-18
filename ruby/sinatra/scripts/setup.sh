#!/bin/bash
set -e

echo "🚀 Setting up Sinatra API Template..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from env.example..."
    if [ -f env.example ]; then
        cp env.example .env
    else
        echo "⚠️ env.example not found, creating basic .env file..."
        cat > .env << EOF
RACK_ENV=development
DATABASE_URL=postgresql://postgres:password@db:5432/sinatra_api_development
REDIS_URL=redis://redis:6379/0
JWT_SECRET=development-jwt-secret-change-in-production
EOF
    fi
fi

# Build Docker images
echo "🏗️ Building Docker images..."
docker compose build

# Create and setup database
echo "🗄️ Setting up database..."
docker compose run --rm api bundle exec rake db:create
docker compose run --rm api bundle exec rake db:migrate
docker compose run --rm api bundle exec rake db:seed

# Install dependencies
echo "📦 Installing dependencies..."
docker compose run --rm api bundle install

echo "✅ Setup complete!"
echo ""
echo "🚀 To start the development server, run:"
echo "   ./scripts/dev.sh"
echo ""
echo "🌐 Your API will be available at:"
echo "   http://localhost:3000"
echo ""
echo "📖 API Documentation:"
echo "   http://localhost:3000/docs" 