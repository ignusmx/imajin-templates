# 🚀 Production Deployment Guide - Sinatra API Template

## 🎯 Overview

This guide covers deploying the Sinatra API template to production environments including Heroku, AWS, DigitalOcean, and Docker-based deployments.

## 📋 Pre-deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations tested
- [ ] SSL/TLS certificates ready
- [ ] Health checks implemented  
- [ ] Monitoring and logging configured
- [ ] Security hardening completed
- [ ] Performance optimization applied
- [ ] Backup strategy implemented

## 🌊 Heroku Deployment

### **Quick Deploy**
```bash
# Install Heroku CLI
brew install heroku/brew/heroku

# Login and create app
heroku login
heroku create your-sinatra-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Add Redis
heroku addons:create heroku-redis:hobby-dev

# Set environment variables
heroku config:set RACK_ENV=production
heroku config:set JWT_SECRET=$(openssl rand -hex 32)
heroku config:set CORS_ORIGINS=https://yourfrontend.com

# Deploy
git push heroku main

# Run migrations
heroku run bundle exec rake db:migrate
heroku run bundle exec rake db:seed

# View logs
heroku logs --tail
```

### **Heroku Configuration**
```bash
# Scale dynos
heroku ps:scale web=1

# Enable automatic SSL
heroku certs:auto:enable

# Set custom domain
heroku domains:add api.yourdomain.com

# Configure buildpacks
heroku buildpacks:set heroku/ruby
```

### **Heroku Environment Variables**
```bash
heroku config:set RACK_ENV=production
heroku config:set JWT_SECRET=your-production-jwt-secret
heroku config:set JWT_EXPIRATION=86400
heroku config:set CORS_ORIGINS=https://yourdomain.com
heroku config:set LOG_LEVEL=info
heroku config:set ENABLE_SWAGGER_DOCS=false
```

## ☁️ AWS Deployment

### **AWS ECS with Fargate**

1. **Build and Push Docker Image**:
```bash
# Build production image
docker build -t sinatra-api --target production .

# Tag for ECR
docker tag sinatra-api:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/sinatra-api:latest

# Push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/sinatra-api:latest
```

2. **ECS Task Definition** (`ecs-task-definition.json`):
```json
{
  "family": "sinatra-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::123456789:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "sinatra-api",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/sinatra-api:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "RACK_ENV", "value": "production"},
        {"name": "DATABASE_URL", "value": "postgresql://..."},
        {"name": "REDIS_URL", "value": "redis://..."},
        {"name": "JWT_SECRET", "value": "your-secret"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/sinatra-api",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
```

3. **Deploy with AWS CLI**:
```bash
# Register task definition
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json

# Update service
aws ecs update-service --cluster production --service sinatra-api --task-definition sinatra-api:1
```

### **AWS RDS Setup**
```bash
# Create PostgreSQL instance
aws rds create-db-instance \
  --db-instance-identifier sinatra-api-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password your-password \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-12345678
```

## 🌊 DigitalOcean Deployment

### **DigitalOcean App Platform**

1. **Create `app.yaml`**:
```yaml
name: sinatra-api
services:
- name: api
  source_dir: /
  github:
    repo: your-username/sinatra-api
    branch: main
  run_command: bundle exec puma -C config/puma.rb
  environment_slug: ruby
  instance_count: 1
  instance_size_slug: basic-xxs
  http_port: 3000
  env:
  - key: RACK_ENV
    value: production
  - key: JWT_SECRET
    value: your-jwt-secret
    type: SECRET
  - key: DATABASE_URL
    value: ${db.DATABASE_URL}
  - key: REDIS_URL
    value: ${redis.DATABASE_URL}

databases:
- name: db
  engine: PG
  version: "13"
  size: db-s-dev-database

- name: redis
  engine: REDIS
  version: "6"
```

2. **Deploy**:
```bash
# Install doctl
brew install doctl

# Authenticate
doctl auth init

# Deploy app
doctl apps create --spec app.yaml
```

### **DigitalOcean Droplet with Docker**

1. **Setup Script** (`deploy/setup-droplet.sh`):
```bash
#!/bin/bash
set -e

# Update system
apt-get update && apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Setup firewall
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable

# Setup SSL with Let's Encrypt
apt-get install -y certbot
```

2. **Production Docker Compose** (`docker-compose.prod.yml`):
```yaml
services:
  api:
    build:
      context: .
      target: production
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - RACK_ENV=production
      - DATABASE_URL=postgresql://postgres:${POSTGRES_PASSWORD}@db:5432/sinatra_api_production
      - REDIS_URL=redis://redis:6379/0
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: sinatra_api_production
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data
    ports:
      - "127.0.0.1:6379:6379"

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - /etc/letsencrypt:/etc/letsencrypt
    depends_on:
      - api

volumes:
  postgres_data:
  redis_data:
```

## 🔧 Environment Configuration

### **Production Environment Variables**
```bash
# Application
RACK_ENV=production
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@host:5432/database
REDIS_URL=redis://host:6379/0

# Security
JWT_SECRET=your-super-secure-jwt-secret-64-chars-minimum
JWT_EXPIRATION=86400

# CORS
CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
CORS_ALLOW_CREDENTIALS=true

# API
API_VERSION=v1
API_BASE_PATH=/api

# Logging
LOG_LEVEL=info
LOG_FORMAT=json

# Features  
ENABLE_SWAGGER_DOCS=false
ENABLE_RATE_LIMITING=true

# External services
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

### **Secure Secret Generation**
```bash
# Generate JWT secret
openssl rand -hex 32

# Generate Rails-like secret
openssl rand -base64 32

# Generate UUID
uuidgen
```

## 🔒 Security Hardening

### **SSL/TLS Configuration**
```bash
# Generate Let's Encrypt certificate
certbot certonly --standalone -d api.yourdomain.com

# Auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
```

### **Nginx Configuration** (`nginx.conf`):
```nginx
events {
    worker_connections 1024;
}

http {
    upstream api {
        server api:3000;
    }

    server {
        listen 80;
        server_name api.yourdomain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.yourdomain.com;

        ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

        # Rate limiting
        limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

        location / {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### **Database Security**
```bash
# Create dedicated database user
CREATE USER sinatra_api WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE sinatra_api_production TO sinatra_api;
GRANT USAGE ON SCHEMA public TO sinatra_api;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sinatra_api;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sinatra_api;
```

## 📊 Monitoring & Logging

### **Health Checks**
```ruby
# config/application.rb
get '/health' do
  # Check database
  DB.test_connection
  
  # Check Redis
  redis = Redis.new(url: ENV['REDIS_URL'])
  redis.ping
  
  json(
    status: 'ok',
    timestamp: Time.now.iso8601,
    version: ENV.fetch('APP_VERSION', '1.0.0'),
    environment: ENV.fetch('RACK_ENV', 'development')
  )
rescue => e
  status 503
  json error: 'Service unavailable', details: e.message
end
```

### **Application Monitoring**
```ruby
# Add to Gemfile
gem 'sentry-ruby'

# config/application.rb
configure :production do
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  end
end
```

### **Logging Configuration**
```ruby
# config/application.rb
configure :production do
  # Structured JSON logging
  logger = Logger.new(STDOUT)
  logger.formatter = proc do |severity, datetime, progname, msg|
    {
      level: severity,
      timestamp: datetime.iso8601,
      message: msg,
      service: 'sinatra-api'
    }.to_json + "\n"
  end
  
  set :logger, logger
end
```

## 🚀 CI/CD Deployment

### **GitHub Actions Deployment**
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: "your-sinatra-api"
          heroku_email: "your-email@example.com"
          
      - name: Run Database Migrations
        run: |
          heroku run bundle exec rake db:migrate -a your-sinatra-api
```

### **Automated Deployment Script**
```bash
#!/bin/bash
# deploy/deploy.sh
set -e

echo "🚀 Deploying Sinatra API to production..."

# Build and test
docker compose -f docker-compose.test.yml up --build --exit-code-from test

# Deploy to production
case $1 in
  heroku)
    git push heroku main
    heroku run bundle exec rake db:migrate
    ;;
  docker)
    docker compose -f docker-compose.prod.yml up -d --build
    docker compose -f docker-compose.prod.yml exec api bundle exec rake db:migrate
    ;;
  *)
    echo "Usage: $0 {heroku|docker}"
    exit 1
    ;;
esac

echo "✅ Deployment complete!"
```

## 🔄 Database Migrations

### **Production Migration Strategy**
```bash
# Backup database before migration
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d_%H%M%S).sql

# Run migrations
bundle exec rake db:migrate

# Verify migration
bundle exec rake db:status
```

### **Zero-downtime Deployments**
1. Deploy new version alongside old
2. Run database migrations (ensure backward compatibility)
3. Switch traffic to new version
4. Monitor health checks
5. Remove old version

## 📈 Performance Optimization

### **Database Optimization**
```ruby
# config/database.rb
DB = Sequel.connect(DATABASE_URL,
  max_connections: ENV.fetch('DB_POOL_SIZE', 10).to_i,
  pool_timeout: 10,
  test: false,
  # Connection pooling
  pool_class: :threaded
)

# Add database indexes
add_index :users, :email, unique: true
add_index :posts, :user_id
add_index :posts, :created_at
```

### **Caching Strategy**
```ruby
# Redis caching
redis = Redis.new(url: ENV['REDIS_URL'])

# Cache expensive queries
def cached_user_posts(user_id)
  cache_key = "user:#{user_id}:posts"
  
  cached = redis.get(cache_key)
  return JSON.parse(cached) if cached
  
  posts = Post.where(user_id: user_id).all
  redis.setex(cache_key, 300, posts.to_json) # 5 minutes
  
  posts
end
```

### **Application Performance**
```ruby
# Puma configuration (config/puma.rb)
workers ENV.fetch('WEB_CONCURRENCY', 2).to_i
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

preload_app!

port ENV.fetch('PORT', 3000)
environment ENV.fetch('RACK_ENV', 'development')

before_fork do
  DB.disconnect if defined?(DB)
end

on_worker_boot do
  DB.test_connection if defined?(DB)
end
```

## 🛠️ Troubleshooting

### **Common Production Issues**

**Database Connection Pool Exhausted**
```bash
# Check pool size
heroku config:get DATABASE_URL
# Increase pool size
heroku config:set DB_POOL_SIZE=20
```

**Memory Issues**
```bash
# Monitor memory usage
heroku logs --ps web.1 --tail | grep "Memory"
# Scale up dyno
heroku ps:scale web=1:standard-1x
```

**SSL Certificate Issues**
```bash
# Check certificate status
openssl s_client -connect api.yourdomain.com:443 -servername api.yourdomain.com

# Renew Let's Encrypt certificate
certbot renew --dry-run
```

### **Rollback Procedures**
```bash
# Heroku rollback
heroku rollback v123

# Docker rollback
docker compose -f docker-compose.prod.yml up -d sinatra-api:previous-tag

# Database rollback
bundle exec rake db:rollback STEP=1
```

## 📋 Production Checklist

### **Before Go-Live**
- [ ] Load testing completed
- [ ] Security scan passed
- [ ] SSL certificates installed
- [ ] Monitoring configured
- [ ] Backups scheduled
- [ ] Error tracking setup
- [ ] Performance baseline established

### **Post-Deployment**
- [ ] Health checks passing
- [ ] Logs are clean
- [ ] Performance metrics normal
- [ ] Error rates acceptable
- [ ] SSL grade A+ on SSL Labs
- [ ] Security headers configured

## 📞 Support & Maintenance

### **Monitoring Alerts**
- Application errors > 1%
- Response time > 500ms
- Database connections > 80%
- Memory usage > 80%
- Disk space > 85%
- SSL certificate expiry < 30 days

### **Maintenance Windows**
- Database maintenance: Sundays 2-4 AM UTC
- Application updates: During low traffic periods
- Security patches: As needed with 24h notice

---

**🎯 Remember: Always test deployments in staging before production!** 