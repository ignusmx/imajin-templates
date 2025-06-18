#!/bin/bash
set -e

echo "🚀 Setting up Rails Docker Template..."

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
    echo "📝 Creating .env file from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        echo "⚠️ .env.example not found, creating basic .env file..."
        cat > .env << EOF
RAILS_ENV=development
DATABASE_URL=postgresql://postgres:password@db:5432/app_development
REDIS_URL=redis://redis:6379/0
EOF
    fi
fi

# Build Docker images
echo "🏗️ Building Docker images..."
docker compose build

# Create and setup database
echo "🗄️ Setting up database..."
docker compose run --rm app bin/rails db:create
docker compose run --rm app bin/rails db:migrate
docker compose run --rm app bin/rails db:seed

# Install dependencies
echo "📦 Installing dependencies..."
docker compose run --rm app bundle install

# Precompile assets
echo "🎨 Precompiling assets..."
docker compose run --rm app bin/rails assets:precompile

echo "✅ Setup complete!"
echo ""
echo "🚀 To start the development server, run:"
echo "   ./scripts/dev.sh"
echo ""
echo "🌐 Your application will be available at:"
echo "   http://localhost:3000" 