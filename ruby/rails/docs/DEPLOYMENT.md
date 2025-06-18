# Deployment Guide

This guide covers production deployment options for the Rails Docker Template.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- PostgreSQL database (external)
- Redis instance (external)
- SSL certificate
- Domain name

## Production Environment Variables

Set these environment variables in your production environment:

```env
# Rails Environment
RAILS_ENV=production
RAILS_LOG_LEVEL=info
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Security
SECRET_KEY_BASE=<generate-with-rails-secret>
RAILS_MASTER_KEY=<your-master-key>

# Database
DATABASE_URL=postgresql://user:password@host:5432/database_name

# Redis
REDIS_URL=redis://host:6379/0

# Application
APP_HOST=yourdomain.com
APP_PORT=3000

# SSL
FORCE_SSL=true

# External Services
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# AWS_REGION=
# S3_BUCKET=

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
FROM_EMAIL=noreply@yourdomain.com
```

## Docker Production Build

### Building Production Image

```bash
# Build production image
docker build -t your-app:latest --target production .

# Or with BuildKit for better caching
DOCKER_BUILDKIT=1 docker build -t your-app:latest --target production .

# Tag for registry
docker tag your-app:latest registry.example.com/your-app:latest

# Push to registry
docker push registry.example.com/your-app:latest
```

### Production Docker Compose

Create `docker-compose.prod.yml`:

```yaml
version: "3.9"

services:
  app:
    image: your-app:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    depends_on:
      - nginx

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app

  sidekiq:
    image: your-app:latest
    restart: unless-stopped
    command: bundle exec sidekiq
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
```

## Deployment Platforms

### 1. DigitalOcean App Platform

Create `app.yaml`:

```yaml
name: rails-app
services:
- name: web
  source_dir: /
  github:
    repo: your-username/your-repo
    branch: main
  run_command: bin/rails server -b 0.0.0.0 -p $PORT
  environment_slug: ruby
  instance_count: 1
  instance_size_slug: basic-xxs
  envs:
  - key: RAILS_ENV
    value: production
  - key: DATABASE_URL
    value: ${db.DATABASE_URL}
  - key: REDIS_URL
    value: ${redis.REDIS_URL}
  
databases:
- name: db
  engine: PG
  version: "13"
  
services:
- name: redis
  engine: REDIS
  version: "6"
```

### 2. Heroku

```bash
# Install Heroku CLI
# Create Heroku app
heroku create your-app-name

# Add buildpacks
heroku buildpacks:add heroku/ruby

# Add addons
heroku addons:create heroku-postgresql:hobby-dev
heroku addons:create heroku-redis:hobby-dev

# Set environment variables
heroku config:set RAILS_MASTER_KEY=your-master-key
heroku config:set SECRET_KEY_BASE=$(rails secret)

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
```

### 3. AWS ECS

Create `ecs-task-definition.json`:

```json
{
  "family": "rails-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "rails-app",
      "image": "your-account.dkr.ecr.region.amazonaws.com/rails-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "RAILS_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:rails-app/database-url"
        },
        {
          "name": "SECRET_KEY_BASE",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:rails-app/secret-key-base"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/rails-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### 4. Google Cloud Run

```yaml
# cloudbuild.yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/rails-app:$COMMIT_SHA', '--target', 'production', '.']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/rails-app:$COMMIT_SHA']
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['run', 'deploy', 'rails-app', '--image', 'gcr.io/$PROJECT_ID/rails-app:$COMMIT_SHA', '--region', 'us-central1', '--platform', 'managed']
```

## Database Setup

### PostgreSQL (Production)

```sql
-- Create database and user
CREATE DATABASE app_production;
CREATE USER app_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE app_production TO app_user;

-- Set connection limit
ALTER USER app_user CONNECTION LIMIT 20;
```

### Database Migrations

```bash
# Run migrations in production
docker run --rm -e DATABASE_URL=$DATABASE_URL your-app:latest bin/rails db:migrate

# Or with docker-compose
docker-compose -f docker-compose.prod.yml run --rm app bin/rails db:migrate
```

## SSL/TLS Configuration

### Nginx Configuration

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream app {
        server app:3000;
    }

    server {
        listen 80;
        server_name yourdomain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name yourdomain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## Monitoring and Logging

### Health Checks

The application includes health check endpoints:

- `/health` - Application health
- `/health/database` - Database connectivity
- `/health/redis` - Redis connectivity

### Logging

Configure structured logging for production:

```ruby
# config/environments/production.rb
config.log_formatter = ::Logger::Formatter.new
config.logger = ActiveSupport::Logger.new(STDOUT)
config.log_level = :info
```

### Error Tracking

Add error tracking service:

```ruby
# Gemfile
gem 'sentry-rails'

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
end
```

## Performance Optimization

### Database

- Use connection pooling
- Enable query caching
- Set up read replicas
- Regular maintenance (VACUUM, ANALYZE)

### Caching

```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 1.hour
}
```

### Background Jobs

```yaml
# docker-compose.prod.yml
sidekiq:
  image: your-app:latest
  command: bundle exec sidekiq -C config/sidekiq.yml
  replicas: 2
```

## Security Checklist

- [ ] Use HTTPS everywhere
- [ ] Set secure environment variables
- [ ] Enable CSRF protection
- [ ] Configure CORS properly
- [ ] Use strong passwords
- [ ] Regular security audits
- [ ] Keep dependencies updated
- [ ] Enable database encryption
- [ ] Set up proper firewall rules
- [ ] Monitor for suspicious activity

## Backup Strategy

### Database Backups

```bash
# Automated database backup
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql

# Restore from backup
psql $DATABASE_URL < backup-20231201.sql
```

### File Backups

```bash
# Backup uploaded files (if using local storage)
tar -czf uploads-backup-$(date +%Y%m%d).tar.gz storage/
```

## Rollback Procedures

### Application Rollback

```bash
# Rollback to previous image
docker tag your-app:previous your-app:latest
docker-compose -f docker-compose.prod.yml up -d app

# Or use orchestration tools
kubectl rollout undo deployment/rails-app
```

### Database Rollback

```bash
# Rollback database migrations
docker-compose -f docker-compose.prod.yml run --rm app bin/rails db:rollback STEP=1
```

## Scaling

### Horizontal Scaling

```yaml
# docker-compose.prod.yml
services:
  app:
    image: your-app:latest
    deploy:
      replicas: 3
    # ... rest of configuration
```

### Load Balancing

Use nginx, HAProxy, or cloud load balancers to distribute traffic across multiple application instances.

## Cost Optimization

1. **Right-size your instances**
2. **Use reserved instances for predictable workloads**
3. **Implement auto-scaling**
4. **Monitor resource usage**
5. **Clean up unused resources**
6. **Use CDN for static assets**
7. **Optimize Docker images** 