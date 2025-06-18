#!/bin/bash
set -e

echo "🧪 Running Rails test suite..."

# Ensure test database is ready
echo "🗄️ Preparing test database..."
docker compose run --rm -e RAILS_ENV=test app bin/rails db:create db:migrate

# Run linting
echo "🔍 Running code linting..."
docker compose run --rm app bundle exec rubocop

# Run security audit
echo "🔒 Running security audit..."
docker compose run --rm app bundle exec brakeman -q

# Run RSpec tests
echo "🧪 Running RSpec tests..."
docker compose run --rm -e RAILS_ENV=test app bundle exec rspec

# Run system tests
echo "🖥️ Running system tests..."
docker compose run --rm -e RAILS_ENV=test app bin/rails test:system

echo "✅ All tests passed!" 