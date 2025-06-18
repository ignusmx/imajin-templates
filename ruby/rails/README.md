# Rails Docker Template

## 🎯 Overview

A modern, production-ready Rails application template with Docker-first development, PostgreSQL, Redis, and comprehensive tooling. Built for developers who want to go from git clone to running application in under 2 minutes.

### Key Features

- **Rails 8.0.2** with Ruby 3.2.8
- **Docker-first development** with multi-stage builds
- **PostgreSQL 15** and **Redis 7** with Alpine Linux
- **Comprehensive testing** with RSpec and Factory Bot
- **Code quality tools** (Rubocop, Brakeman, Bullet)
- **Modern tooling** (Tailwind CSS, Background jobs, Health checks)
- **Production-ready** with security best practices
- **CI/CD pipeline** with GitHub Actions

## 📋 Prerequisites

- Docker & Docker Compose
- Git

## ⚡ Quick Start

```bash
git clone <repository-url>
cd rails-template
./scripts/setup.sh
./scripts/dev.sh
```

Open http://localhost:3000

## 🔧 Development

### Starting the Application

```bash
# Start all services
./scripts/dev.sh

# Or manually with docker-compose
docker-compose up --build

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f app
```

### Database Operations

```bash
# Create and migrate database
docker-compose run --rm app bin/rails db:create db:migrate

# Seed database with sample data
docker-compose run --rm app bin/rails db:seed

# Reset database (drops, creates, migrates, seeds)  
docker-compose run --rm app bin/rails db:reset

# Access Rails console
docker-compose run --rm app bin/rails console

# Connect to PostgreSQL directly
docker-compose exec db psql -U postgres -d app_development
```

### Running Gems and Dependencies

```bash
# Install new gems (after updating Gemfile)
docker-compose build app
docker-compose run --rm app bundle install

# Update gems
docker-compose run --rm app bundle update

# Run Rails generators
docker-compose run --rm app bin/rails generate controller Pages home
docker-compose run --rm app bin/rails generate model User name:string email:string
```

## 📁 Project Structure

```
├── app/                    # Rails application code
│   ├── controllers/        # HTTP request controllers
│   ├── models/            # Data models and business logic
│   ├── views/             # HTML templates
│   ├── services/          # Business logic services
│   └── jobs/              # Background job classes
├── config/                # Rails configuration
│   ├── environments/      # Environment-specific config
│   └── initializers/      # App initialization code
├── db/                    # Database files
│   ├── migrate/           # Database migrations
│   └── seeds.rb          # Sample data
├── spec/                  # RSpec tests
│   ├── factories/         # Test data factories
│   ├── models/           # Model tests
│   ├── requests/         # API/controller tests
│   └── system/           # End-to-end tests
├── scripts/              # Automation scripts
│   ├── setup.sh          # Initial setup
│   ├── dev.sh            # Start development
│   └── test.sh           # Run test suite
├── docs/                 # Documentation
│   ├── DEVELOPMENT.md    # Development guide
│   ├── DEPLOYMENT.md     # Deployment guide
│   └── ARCHITECTURE.md   # Architecture decisions
├── .github/              # GitHub Actions workflows
│   └── workflows/        # CI/CD pipelines
├── Dockerfile            # Multi-stage Docker build
├── docker-compose.yml    # Development services
└── .env.example         # Environment variables template
```

## 🛠️ Available Scripts

### Setup and Development

```bash
./scripts/setup.sh    # One-time setup (creates DB, installs deps)
./scripts/dev.sh      # Start development environment
./scripts/test.sh     # Run complete test suite
```

### Manual Commands

```bash
# Run tests
docker-compose run --rm app bundle exec rspec
docker-compose run --rm app bin/rails test:system

# Code quality
docker-compose run --rm app bundle exec rubocop
docker-compose run --rm app bundle exec brakeman

# Background jobs (if using Sidekiq)
docker-compose run --rm app bundle exec sidekiq

# Asset compilation
docker-compose run --rm app bin/rails tailwindcss:build
docker-compose run --rm app bin/rails assets:precompile
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
./scripts/test.sh

# Run specific test types
docker-compose run --rm app bundle exec rspec spec/models/
docker-compose run --rm app bundle exec rspec spec/requests/
docker-compose run --rm app bin/rails test:system

# Run with coverage
docker-compose run --rm app bundle exec rspec --format documentation
```

### Test Structure

- **Unit Tests**: Models, services, and business logic
- **Integration Tests**: API endpoints and workflows  
- **System Tests**: End-to-end user interactions
- **Security Tests**: Brakeman vulnerability scanning
- **Performance Tests**: N+1 query detection with Bullet

## 🚀 Deployment

### Production Build

```bash
# Build production image
docker build -t rails-app:latest --target production .

# Run production container
docker run -p 3000:3000 --env-file .env.production rails-app:latest
   ```

### Environment Variables

Copy `.env.example` to `.env` and configure:

```env
# Database
DATABASE_URL=postgresql://user:password@host:5432/database

# Redis
REDIS_URL=redis://host:6379/0

# Security (generate with `rails secret`)
SECRET_KEY_BASE=your_secret_key
RAILS_MASTER_KEY=your_master_key

# Application
RAILS_ENV=production
APP_HOST=yourdomain.com
```

### Deployment Platforms

- **Docker Compose**: See `docs/DEPLOYMENT.md`
- **Heroku**: Automatic buildpack detection
- **AWS ECS**: Container orchestration
- **Google Cloud Run**: Serverless containers
- **DigitalOcean App Platform**: Managed deployment

## 🔧 Configuration

### Services

- **Web Application**: http://localhost:3000
- **PostgreSQL Database**: localhost:5432
- **Redis Cache**: localhost:6379
- **MailHog (Email Testing)**: http://localhost:8025

### Development Tools

- **Hot Reload**: Automatic code reloading
- **Debugging**: Pry and debugging gems included
- **File Watching**: Watchman for fast change detection
- **Email Testing**: MailHog for development emails

## 🏗️ Architecture

### Technology Stack

- **Ruby 3.2.8** - Latest stable Ruby
- **Rails 8.0.2** - Modern Rails with performance improvements
- **PostgreSQL 15** - Robust relational database
- **Redis 7** - Caching and background job queue
- **Alpine Linux** - Lightweight Docker images
- **Tailwind CSS** - Utility-first styling
- **RSpec** - Behavior-driven testing
- **Docker** - Containerized development and deployment

### Design Patterns

- **Service Objects** - Complex business logic
- **Repository Pattern** - Data access abstraction
- **Background Jobs** - Async processing with Sidekiq
- **Caching Strategy** - Multi-level caching with Redis
- **Health Checks** - Application and dependency monitoring

## 🔒 Security

### Security Features

- **HTTPS/TLS** - Encrypted communication
- **CSRF Protection** - Cross-site request forgery prevention
- **SQL Injection Prevention** - Parameterized queries
- **XSS Protection** - Content sanitization
- **Security Headers** - Secure HTTP headers
- **Dependency Scanning** - Automated vulnerability detection

### Security Tools

- **Brakeman** - Static analysis security scanner
- **Bundler Audit** - Gem vulnerability checking
- **Strong Migrations** - Safe database migrations
- **Content Security Policy** - XSS attack mitigation

## 🚨 Troubleshooting

### Common Issues

**Port Already in Use**
```bash
# Find and kill process using port 3000
lsof -i :3000
kill -9 <PID>
```

**Database Connection Issues**
```bash
# Restart database service
docker-compose restart db

# Check database status
docker-compose exec db pg_isready -U postgres
```

**Bundle Install Issues**
```bash
# Rebuild Docker image
docker-compose build --no-cache app

# Clear bundle cache
docker-compose run --rm app bundle install --clean
```

**Permission Issues**
```bash
# Fix file permissions (Linux/macOS)
sudo chown -R $USER:$USER .
```

### Getting Help

1. Check the logs: `docker-compose logs app`
2. Access container shell: `docker-compose exec app bash`
3. Review documentation in `docs/` directory
4. Check GitHub Issues for known problems

## 📚 Documentation

- [Development Guide](docs/DEVELOPMENT.md) - Detailed development workflow
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment options
- [Architecture Guide](docs/ARCHITECTURE.md) - Design decisions and patterns

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the coding standards
4. Run the test suite (`./scripts/test.sh`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Standards

- Follow Ruby and Rails best practices
- Write tests for new functionality
- Maintain code coverage above 90%
- Use descriptive commit messages
- Update documentation for significant changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Rails community for the amazing framework
- Docker team for containerization technology
- Contributors to all the open-source gems used
- Alpine Linux for lightweight base images

---

**Built with ❤️ for developers who value quality, security, and developer experience.**
