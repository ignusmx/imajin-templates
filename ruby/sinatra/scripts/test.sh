#!/bin/bash
set -e

echo "🧪 Running Sinatra API test suite..."

# Ensure test database is ready
echo "🗄️ Preparing test database..."
docker compose run --rm -e RACK_ENV=test api bundle exec rake db:create db:migrate

# Run linting
echo "🔍 Running code linting..."
docker compose run --rm api bundle exec rubocop

# Run security audit
echo "🔒 Running security audit..."
docker compose run --rm api bundle exec brakeman -q
docker compose run --rm api bundle exec bundle-audit check --update

# Run RSpec tests
echo "🧪 Running RSpec tests..."
docker compose run --rm -e RACK_ENV=test api bundle exec rspec

echo "✅ All tests passed!" 