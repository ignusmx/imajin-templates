# Laravel Docker Template

A production-ready Laravel starter template with Docker-first development, PostgreSQL, Redis, and modern PHP tooling.

## 🎯 Overview

This template provides a complete Laravel development environment with:

- **Laravel 11** with PHP 8.3
- **Docker-first development** with multi-stage builds
- **PostgreSQL** database with Redis caching
- **Vite** for modern frontend asset building
- **Comprehensive testing** with PHPUnit and coverage
- **Code quality tools** (Pint, PHPStan, security audits)
- **CI/CD pipeline** with GitHub Actions
- **Production-ready** deployment configuration

## 📋 Prerequisites

- **Docker** & **Docker Compose** (latest versions)
- **Git** for version control
- **2GB+ RAM** for optimal performance

## ⚡ Quick Start

```bash
# Clone the template
git clone <your-repo-url> my-laravel-app
cd my-laravel-app

# Setup and start development environment
./scripts/setup.sh
./scripts/dev.sh

# Open your browser
open http://localhost:3000
```

**That's it!** Your Laravel application is now running with database, cache, and all services ready.

## 🔧 Development Setup

### **Automated Setup (Recommended)**

The setup script handles everything:

```bash
./scripts/setup.sh
```

This will:
- Check Docker installation
- Create `.env` file from example
- Generate Laravel application key
- Build Docker containers
- Install PHP and Node.js dependencies
- Run database migrations
- Set proper permissions

### **Manual Setup**

If you prefer manual setup:

```bash
# Copy environment file
cp .env.example .env

# Build and start containers
docker compose up --build -d

# Install dependencies
docker compose exec app composer install
docker compose exec app npm install

# Generate application key
docker compose exec app php artisan key:generate

# Run migrations
docker compose exec app php artisan migrate
```

## 🛠️ Available Scripts

### **Development Scripts**

```bash
# Start development environment
./scripts/dev.sh

# Run all tests
./scripts/test.sh

# Run specific test types
./scripts/test.sh unit
./scripts/test.sh feature
./scripts/test.sh --coverage

# Setup fresh environment
./scripts/setup.sh
```

### **Docker Commands**

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f app

# Access application container
docker compose exec app bash

# Run Artisan commands
docker compose exec app php artisan [command]

# Stop all services
docker compose down

# Reset everything
docker compose down -v && docker compose up --build -d
```

## 🌐 Services

The development environment includes:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Laravel App** | http://localhost:3000 | - |
| **PostgreSQL** | localhost:5432 | postgres/password |
| **Redis** | localhost:6379 | - |

## 🧪 Testing

```bash
# Run all tests
./scripts/test.sh

# Run with coverage
./scripts/test.sh --coverage

# Run specific test types
./scripts/test.sh unit
./scripts/test.sh feature
./scripts/test.sh lint
./scripts/test.sh security
```

## 🚀 Deployment

### **Production Build**

```bash
# Build production image
docker build --target production -t my-laravel-app:latest .

# Test production image
docker run --rm -p 3000:3000 my-laravel-app:latest
```

### **Production Environment**

```bash
# Start production stack
docker compose -f docker-compose.prod.yml up -d

# Monitor services
docker compose -f docker-compose.prod.yml logs -f
```

## 🐛 Troubleshooting

### **Common Issues**

**Port already in use:**
```bash
# Check what's using port 3000
lsof -i :3000

# Stop conflicting services
docker compose down
```

**Database connection errors:**
```bash
# Check database status
docker compose exec db pg_isready -U postgres

# Restart database
docker compose restart db
```

**Permission issues:**
```bash
# Fix Laravel permissions
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
docker compose exec app chmod -R 775 storage bootstrap/cache
```

## 📚 Documentation

- [Development Guide](./docs/DEVELOPMENT.md) - Advanced development workflows
- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)

## 📄 License

This template is open-sourced software licensed under the [MIT license](LICENSE).

---

**Happy coding with Laravel! 🚀**