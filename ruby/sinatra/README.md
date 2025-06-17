# 🚀 Ruby/Sinatra API Template

A lightweight, production-ready Ruby/Sinatra template for building modern JSON APIs and microservices.

## 🎯 Overview

This template provides a robust foundation for building RESTful APIs with Sinatra, featuring:

- **Fast & Lightweight**: Minimal overhead compared to Rails
- **Production-Ready**: Security, logging, error handling built-in
- **Modern Tooling**: Auto-reloading, testing, linting pre-configured
- **API-First**: JSON responses, OpenAPI documentation, CORS support
- **Authentication**: JWT-based auth system ready to use
- **Database**: Sequel ORM with PostgreSQL support
- **Testing**: Comprehensive test suite with RSpec

## 📋 Prerequisites

- **Ruby**: 3.0+ (3.2+ recommended)
- **PostgreSQL**: 14+ (or SQLite for development)
- **Redis**: 6+ (for sessions/caching - optional)
- **Docker & Docker Compose**: For containerized development

## ⚡ Quick Start

1. **Copy the template**:
   ```bash
   cp -r templates/ruby/sinatra my-api-project
   cd my-api-project
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Setup environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

4. **Setup database**:
   ```bash
   bundle exec rake db:create
   bundle exec rake db:migrate
   bundle exec rake db:seed
   ```

5. **Start the server**:
   ```bash
   bundle exec rackup -p 3000
   # or for development with auto-reload:
   bundle exec rerun rackup
   ```

6. **Test the API**:
   ```bash
   curl http://localhost:3000/health
   # Should return: {"status":"ok","timestamp":"..."}
   ```

## 🔧 Development Setup

### **Using Docker (Recommended)**

```bash
# Start all services (API + PostgreSQL + Redis)
docker-compose up -d

# Run database migrations
docker-compose exec api bundle exec rake db:migrate

# View logs
docker-compose logs -f api
```

### **Local Development**

1. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

2. **Setup pre-commit hooks**:
   ```bash
   bundle exec overcommit --install
   ```

3. **Start development servers**:
   ```bash
   # Terminal 1: Start PostgreSQL (if not using Docker)
   brew services start postgresql

   # Terminal 2: Start Redis (optional)
   brew services start redis

   # Terminal 3: Start API server with auto-reload
   bundle exec rerun rackup
   ```

## 📁 Project Structure

```
sinatra-api/
├── app/
│   ├── controllers/         # API endpoint controllers
│   │   ├── base_controller.rb
│   │   ├── auth_controller.rb
│   │   └── users_controller.rb
│   ├── models/             # Sequel models
│   │   ├── user.rb
│   │   └── concerns/
│   ├── services/           # Business logic services
│   │   ├── auth_service.rb
│   │   └── user_service.rb
│   ├── serializers/        # JSON response serializers
│   │   └── user_serializer.rb
│   └── validators/         # Input validation
│       └── user_validator.rb
├── config/
│   ├── application.rb      # Main app configuration
│   ├── database.rb         # Database connection
│   └── routes.rb          # Route definitions
├── db/
│   ├── migrations/         # Database migrations
│   └── seeds.rb           # Sample data
├── lib/
│   ├── middleware/         # Custom Rack middleware
│   └── extensions/        # Ruby extensions
├── spec/                  # Test suite
│   ├── controllers/
│   ├── models/
│   ├── services/
│   └── spec_helper.rb
├── docs/
│   └── openapi.yml        # API documentation
├── .env.example           # Environment variables template
├── config.ru             # Rack configuration
├── Gemfile               # Ruby dependencies
├── Rakefile              # Rake tasks
└── README.md             # This file
```

## 🛠️ Available Scripts

```bash
# Development
bundle exec rackup                    # Start server
bundle exec rerun rackup             # Start with auto-reload
bundle exec rackup -p 8080           # Start on custom port

# Database
bundle exec rake db:create           # Create database
bundle exec rake db:migrate          # Run migrations
bundle exec rake db:rollback         # Rollback last migration
bundle exec rake db:seed             # Load sample data
bundle exec rake db:reset            # Drop, create, migrate, seed

# Testing
bundle exec rspec                    # Run all tests
bundle exec rspec spec/controllers   # Run controller tests
bundle exec rspec --format doc       # Detailed test output
bundle exec guard                    # Auto-run tests on file changes

# Code Quality
bundle exec rubocop                  # Run linter
bundle exec rubocop -a               # Auto-fix linting issues
bundle exec brakeman                 # Security analysis
bundle exec bundle-audit             # Check for vulnerable gems

# Documentation
bundle exec yard                     # Generate code docs
bundle exec yard server              # Start documentation server
```

## 🌐 API Endpoints

### **Health Check**
- `GET /health` - API health status

### **Authentication**
- `POST /api/v1/auth/login` - User login (returns JWT)
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `DELETE /api/v1/auth/logout` - Logout user

### **Users** (Protected)
- `GET /api/v1/users` - List users
- `POST /api/v1/users` - Create user
- `GET /api/v1/users/:id` - Get user details
- `PUT /api/v1/users/:id` - Update user
- `DELETE /api/v1/users/:id` - Delete user

### **API Documentation**
- `GET /docs` - Swagger UI (API documentation)
- `GET /openapi.json` - OpenAPI specification

## 🔐 Authentication

This template uses JWT (JSON Web Tokens) for authentication:

### **Login Flow**
```bash
# 1. Login with credentials
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Response: {"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."}

# 2. Use token for protected endpoints
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

### **Token Configuration**
```ruby
# config/application.rb
JWT_SECRET = ENV.fetch('JWT_SECRET', 'your-secret-key')
JWT_EXPIRATION = ENV.fetch('JWT_EXPIRATION', '24').to_i.hours
```

## 🧪 Testing

This template includes comprehensive testing with RSpec:

```bash
# Run all tests
bundle exec rspec

# Run with coverage report
COVERAGE=true bundle exec rspec

# Run specific test files
bundle exec rspec spec/controllers/users_controller_spec.rb
bundle exec rspec spec/models/user_spec.rb

# Run tests matching a pattern
bundle exec rspec -t auth
bundle exec rspec -t integration
```

### **Test Structure**
- **Controller tests**: API endpoint testing
- **Model tests**: Database model validation
- **Service tests**: Business logic testing
- **Integration tests**: End-to-end API testing

## 🚀 Deployment

### **Environment Variables**

```bash
# .env (copy from .env.example)
DATABASE_URL=postgresql://user:password@localhost/myapi_production
REDIS_URL=redis://localhost:6379/0
JWT_SECRET=your-super-secret-jwt-key-here
RACK_ENV=production
PORT=3000
CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

### **Docker Deployment**

```bash
# Build production image
docker build -t my-sinatra-api .

# Run container
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://... \
  -e JWT_SECRET=... \
  my-sinatra-api
```

### **Heroku Deployment**

```bash
# Create Heroku app
heroku create my-sinatra-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Set environment variables
heroku config:set JWT_SECRET=your-secret-key
heroku config:set RACK_ENV=production

# Deploy
git push heroku main

# Run migrations
heroku run bundle exec rake db:migrate
```

### **Docker Compose (Production)**

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RACK_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/myapi_prod
    depends_on:
      - db
  
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myapi_prod
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## ⚡ Performance Tips

### **Database Optimization**
- Use database indexes for frequently queried fields
- Implement database connection pooling
- Consider read replicas for high-traffic APIs

### **Caching**
- Use Redis for session storage and caching
- Implement HTTP caching headers
- Cache expensive computations

### **Monitoring**
- Add application performance monitoring (APM)
- Implement health checks for load balancers
- Log structured JSON for better parsing

## 🐛 Troubleshooting

### **Common Issues**

**Database Connection Errors**
```bash
# Check database is running
pg_isready -h localhost -p 5432

# Check environment variables
echo $DATABASE_URL

# Test connection
bundle exec ruby -e "require './config/database'; puts 'DB connected!'"
```

**JWT Token Issues**
```bash
# Verify JWT secret is set
echo $JWT_SECRET

# Test token generation
bundle exec ruby -e "require './app/services/auth_service'; puts AuthService.generate_token(user_id: 1)"
```

**Port Already in Use**
```bash
# Find process using port 3000
lsof -ti:3000

# Kill process
kill -9 $(lsof -ti:3000)
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Write tests for your changes
4. Ensure all tests pass: `bundle exec rspec`
5. Run linting: `bundle exec rubocop`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to the branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

## 📄 License

This template is released under the MIT License. See [LICENSE](LICENSE) for details.

---

**Built with ❤️ for rapid API development with Ruby/Sinatra!** 