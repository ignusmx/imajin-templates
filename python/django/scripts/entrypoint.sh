#!/bin/sh
set -e

# Wait for the database to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 0.1
done
echo "Database started"

# Wait for Redis to be ready
echo "Waiting for Redis..."
while ! nc -z redis 6379; do
  sleep 0.1
done
echo "Redis started"

# Use uv to run commands with the virtual environment
echo "Applying database migrations..."
uv run python manage.py migrate --noinput

echo "Creating superuser if not exists..."
uv run python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
    print('Superuser created: admin/admin')
else:
    print('Superuser already exists')
"

echo "Collecting static files..."
uv run python manage.py collectstatic --noinput
npm run build

# Start the application
echo "Starting Django server..."
exec uv run "$@" 