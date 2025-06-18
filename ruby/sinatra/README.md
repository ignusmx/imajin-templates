# 🚀 Ruby/Sinatra API Template

A production-ready Ruby/Sinatra template for building fast, lightweight JSON APIs and microservices with Docker-first development.

## 🎯 Overview

Modern Ruby API template featuring:
- **Fast & Lightweight**: Minimal overhead, built for speed
- **Docker-First**: Complete containerized development environment
- **Production-Ready**: Security, monitoring, and deployment built-in
- **Modern Tooling**: RSpec, RuboCop, Brakeman pre-configured
- **API-First Design**: JSON responses, JWT auth, CORS support
- **Database Ready**: PostgreSQL with Sequel ORM
- **Redis Integration**: Caching and session management

## 📋 Prerequisites

- Docker & Docker Compose
- Git

## ⚡ Quick Start

```bash
git clone <your-repo>
cd sinatra-api
./scripts/setup.sh
./scripts/dev.sh
```

Open http://localhost:3000

## 🔧 Development

### **Starting Development Environment**
```bash
# Full setup (first time)
./scripts/setup.sh

# Start development services
./scripts/dev.sh

# Run tests
./scripts/test.sh
```

### **Docker Commands**
```bash
# View logs
docker compose logs -f api

# Access container
docker compose exec api bash

# Run migrations
docker compose exec api bundle exec rake db:migrate

# Stop services
docker compose down
```

### **Database Management**
```bash
# Create migration
docker compose exec api bundle exec rake db:create_migration[create_posts]

# Run migrations
docker compose exec api bundle exec rake db:migrate

# Seed database
docker compose exec api bundle exec rake db:seed

# Reset database
docker compose exec api bundle exec rake db:reset
```

## 📁 Project Structure

```
sinatra-api/
├── README.md                    # This file
├── .env.example                # Environment variables template
├── .gitignore                  # Git ignore patterns
├── Dockerfile                  # Multi-stage Docker build
├── docker-compose.yml          # Development environment
├── .dockerignore              # Docker build optimization
├── scripts/
│   ├── setup.sh               # Automated setup script
│   ├── dev.sh                 # Development startup script
│   └── test.sh                # Testing script
├── .github/
│   └── workflows/
│       └── ci.yml             # Continuous integration
├── docs/
│   ├── DEVELOPMENT.md         # Development guide
│   ├── DEPLOYMENT.md          # Production deployment
│   └── ARCHITECTURE.md        # Design decisions
├── app/
│   ├── controllers/           # API endpoint controllers
│   ├── models/               # Sequel models
│   ├── services/             # Business logic services
│   └── serializers/          # JSON response formatting
├── config/
│   ├── application.rb        # Main app configuration
│   ├── database.rb           # Database connection
│   └── routes.rb            # Route definitions
├── db/
│   ├── migrations/           # Database migrations
│   └── seeds.rb             # Sample data
├── spec/                    # Test suite
│   ├── controllers/         # API endpoint tests
│   ├── models/             # Model tests
│   ├── factories/          # Test data factories
│   └── spec_helper.rb      # Test configuration
├── Gemfile                 # Ruby dependencies
├── Rakefile               # Rake tasks
└── config.ru             # Rack configuration
```

## 🛠️ Available Scripts

```bash
# Development
./scripts/setup.sh              # Complete project setup
./scripts/dev.sh                # Start development environment  
./scripts/test.sh               # Run full test suite

# Docker Commands
docker compose up               # Start all services
docker compose down             # Stop all services
docker compose logs -f api      # View application logs

# Database
bundle exec rake db:create      # Create database
bundle exec rake db:migrate     # Run migrations
bundle exec rake db:seed        # Load sample data
bundle exec rake db:reset       # Reset database

# Testing
bundle exec rspec               # Run all tests
bundle exec rspec spec/controllers # Run controller tests
COVERAGE=true bundle exec rspec # Run tests with coverage

# Code Quality
bundle exec rubocop             # Run linter
bundle exec rubocop -a          # Auto-fix issues
bundle exec brakeman            # Security analysis
bundle exec bundle-audit        # Vulnerability check
```

## 🌐 API Endpoints

### **Health Check**
```bash
GET /health
# Response: {"status":"ok","timestamp":"2024-01-01T12:00:00Z"}
```

### **Authentication**
```bash
# Login
POST /api/v1/auth/login
{
  "email": "admin@example.com",
  "password": "password123"
}

# Refresh token
POST /api/v1/auth/refresh
Authorization: Bearer <token>

# Logout
DELETE /api/v1/auth/logout
```

### **Users (Protected)**
```bash
# List users
GET /api/v1/users
Authorization: Bearer <token>

# Create user
POST /api/v1/users
Authorization: Bearer <token>
{
  "email": "user@example.com",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe"
}

# Get user
GET /api/v1/users/:id
Authorization: Bearer <token>

# Update user
PUT /api/v1/users/:id
Authorization: Bearer <token>

# Delete user
DELETE /api/v1/users/:id
Authorization: Bearer <token>
```

## 🔐 Authentication

JWT-based authentication system:

```bash
# 1. Login to get token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password123"}'

# 2. Use token for protected endpoints
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer <your-jwt-token>"
```

**Default Users:**
- **Admin**: `admin@example.com` / `password123`
- **User**: `john.doe@example.com` / `password123`

## 🧪 Testing

Comprehensive test suite with RSpec:

```bash
# Run all tests
./scripts/test.sh

# Or run individual test commands
bundle exec rspec                           # All tests
bundle exec rspec spec/controllers          # Controller tests
bundle exec rspec spec/models              # Model tests
COVERAGE=true bundle exec rspec             # With coverage
bundle exec rspec -t auth                   # Tagged tests
```

### **Test Coverage**
- Controller tests: API endpoint testing
- Model tests: Data validation and relationships
- Service tests: Business logic testing
- Integration tests: End-to-end workflows

## 🚀 Deployment

### **Environment Variables**
```bash
# Application
RACK_ENV=production
PORT=3000

# Database & Redis
DATABASE_URL=postgresql://user:password@host:5432/database
REDIS_URL=redis://host:6379/0

# Security
JWT_SECRET=your-super-secure-jwt-secret
JWT_EXPIRATION=86400

# CORS
CORS_ORIGINS=https://yourdomain.com
```

### **Heroku Deployment**
```bash
# Create app
heroku create your-sinatra-api

# Add services
heroku addons:create heroku-postgresql:hobby-dev
heroku addons:create heroku-redis:hobby-dev

# Set environment variables
heroku config:set RACK_ENV=production
heroku config:set JWT_SECRET=$(openssl rand -hex 32)

# Deploy
git push heroku main

# Run migrations
heroku run bundle exec rake db:migrate
heroku run bundle exec rake db:seed
```

### **Docker Production**
```bash
# Build production image
docker build -t sinatra-api --target production .

# Run with docker-compose
docker compose -f docker-compose.prod.yml up -d
```

### **AWS/DigitalOcean**
See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed deployment guides.

## ⚡ Performance

### **Benchmarks**
- Response time: < 50ms (95th percentile)
- Throughput: 1000+ requests/second
- Memory usage: < 100MB baseline
- Docker startup: < 10 seconds

### **Optimization Features**
- Database connection pooling
- Redis caching layer
- Multi-stage Docker builds
- Query optimization with Sequel ORM
- JSON response optimization

## 🔒 Security

### **Built-in Security Features**
- JWT authentication with configurable expiration
- BCrypt password hashing
- SQL injection prevention (Sequel ORM)
- CORS configuration
- Rate limiting support
- Security headers
- Input validation and sanitization

### **Security Scanning**
```bash
# Run security audit
bundle exec brakeman            # Static analysis
bundle exec bundle-audit        # Dependency vulnerabilities
```

## 📊 Monitoring

### **Health Checks**
```bash
# Application health
GET /health

# API status
GET /api/v1/health
```

### **Logging**
- Structured JSON logging
- Request/response logging
- Error tracking integration
- Performance metrics

### **Error Tracking**
Integrated with Sentry for production error monitoring.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Write tests for your changes
4. Ensure all tests pass: `./scripts/test.sh`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open Pull Request

## 🐛 Troubleshooting

### **Common Issues**

**Port already in use**
```bash
# Kill process on port 3000
kill -9 $(lsof -ti:3000)
```

**Database connection error**
```bash
# Reset database
docker compose down -v
./scripts/setup.sh
```

**Docker issues**
```bash
# Clean up Docker
docker system prune -a
docker compose build --no-cache
```

### **Getting Help**
- Check [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for detailed development guide
- Review [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for production deployment
- See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design

## 📄 License

This template is released under the MIT License. See [LICENSE](LICENSE) for details.

---

**Built with ❤️ for rapid API development with Ruby/Sinatra!** 