# Django Docker Template

A production-ready Django starter template with Docker-first development, Django REST Framework, PostgreSQL, Redis, Celery, and Tailwind CSS 4+.

## 🎯 Overview

This template provides a complete Django development environment with:

- **Django 5** with Python 3.11 and **uv** package management
- **Django REST Framework** for API development
- **Celery** with Redis for background tasks and caching
- **Docker-first development** with multi-stage builds
- **PostgreSQL** database with Redis caching
- **Tailwind CSS 4+** with Alpine.js for modern frontend
- **Comprehensive testing** with Pytest and coverage reporting
- **Code quality tools** (Black, Ruff, MyPy, Bandit, Safety)
- **CI/CD pipeline** with GitHub Actions
- **Production-ready** deployment configuration

## 📋 Prerequisites

- **Docker** & **Docker Compose** (latest versions)
- **Git** for version control
- **2GB+ RAM** for optimal performance

## ⚡ Quick Start

```bash
# Clone the template
git clone <your-repo-url> my-django-app
cd my-django-app

# Setup and start development environment
./scripts/setup.sh
./scripts/dev.sh

# Open your browser
open http://localhost:3000
```

**That's it!** Your Django application is now running with database, cache, Celery workers, and all services ready.

## 🔧 Development Setup

### **Automated Setup (Recommended)**

The setup script handles everything:

```bash
./scripts/setup.sh
```

This will:
- Check Docker installation
- Create `.env` file with secure defaults
- Generate Django secret key
- Build Docker containers
- Install Python and Node.js dependencies with uv
- Run database migrations
- Build Tailwind CSS assets
- Create Django superuser (admin/admin)
- Set proper permissions

### **Manual Setup**

If you prefer manual setup:

```bash
# Copy environment file
cp env.example .env

# Build and start containers
docker compose up --build -d

# Install dependencies
docker compose exec app uv sync --dev
docker compose exec app npm install

# Run migrations
docker compose exec app uv run python manage.py migrate

# Build CSS
docker compose exec app npm run build

# Collect static files
docker compose exec app uv run python manage.py collectstatic --noinput
```

## 🛠️ Available Scripts

### **Development Scripts**

```bash
# Start development environment
./scripts/dev.sh

# Run all tests
./scripts/test.sh

# Test Celery functionality
./scripts/test-celery.sh

# Run specific test types
./scripts/test.sh unit
./scripts/test.sh integration
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

# Run Django management commands
docker compose exec app uv run python manage.py [command]

# Stop all services
docker compose down

# Reset everything
docker compose down -v && docker compose up --build -d
```

### **Package Management with uv**

```bash
# Add Python dependency
docker compose exec app uv add package-name

# Add development dependency
docker compose exec app uv add --dev package-name

# Add Node.js dependency
docker compose exec app npm install package-name

# Build CSS (development)
docker compose exec app npm run dev

# Build CSS (production)
docker compose exec app npm run build
```

## 🌐 Services

The development environment includes:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Django App** | http://localhost:3000 | - |
| **Django Admin** | http://localhost:3000/admin | admin/admin |
| **PostgreSQL** | localhost:5433 | postgres/password |
| **Redis** | localhost:6380 | - |

## 🔄 Celery Background Tasks

The template includes Celery for background task processing:

```bash
# Test Celery functionality
curl http://localhost:3000/test-celery/

# Monitor Celery workers
docker compose logs -f celery

# Monitor Celery beat scheduler
docker compose logs -f celery-beat
```

## 🧪 Testing

```bash
# Run all tests
./scripts/test.sh

# Run with coverage
./scripts/test.sh --coverage

# Run specific test types
./scripts/test.sh unit
./scripts/test.sh integration
./scripts/test.sh api

# Run linting and formatting
./scripts/test.sh lint
./scripts/test.sh format

# Run security checks
./scripts/test.sh security
```

## 🚀 API Endpoints

The template includes sample API endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/status/` | API status information |
| GET | `/api/v1/health/` | Health check with system status |
| GET | `/api/v1/stats/` | Application statistics |
| GET | `/api/v1/items/` | List items with pagination |
| POST | `/api/v1/items/create/` | Create new item |
| POST | `/api/v1/webhook/` | Sample webhook endpoint |
| POST | `/test-celery/` | Test Celery task execution |

### **API Examples**

```bash
# Check API status
curl http://localhost:3000/api/v1/status/

# Health check
curl http://localhost:3000/api/v1/health/

# Test Celery tasks
curl -X POST http://localhost:3000/test-celery/

# Create item
curl -X POST http://localhost:3000/api/v1/items/create/ \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Item", "status": "active"}'
```

## 🎨 Frontend Development

### **Tailwind CSS 4+**

The template uses Tailwind CSS 4+ with modern features:

```bash
# Development build (with watch)
docker compose exec app npm run dev

# Production build (minified)
docker compose exec app npm run build
```

### **Alpine.js Components**

Interactive components are built with Alpine.js:

```html
<!-- Stats counter with animation -->
<div x-data="statsCounter">
  <span x-text="count" data-count="1250"></span>
</div>

<!-- API tester -->
<div x-data="apiTester">
  <button @click="testEndpoint()">Test API</button>
  <pre x-text="response"></pre>
</div>
```

## 📦 Project Structure

```
django-template/
├── apps/
│   ├── core/           # Web views and templates
│   └── api/            # REST API endpoints
├── config/
│   ├── settings/       # Environment-specific settings
│   ├── urls.py         # URL configuration
│   ├── wsgi.py         # WSGI application
│   └── celery.py       # Celery configuration
├── static/
│   ├── css/           # Tailwind CSS files
│   └── js/            # JavaScript files
├── templates/         # Django templates
├── scripts/           # Development scripts
├── logs/              # Application logs
├── Dockerfile         # Multi-stage Docker build
├── docker-compose.yml # Development services
├── pyproject.toml     # Python dependencies (uv)
└── package.json       # Node.js dependencies
```

## 🔒 Security Features

- **Environment-based configuration** with secure defaults
- **CORS protection** with configurable origins
- **CSRF protection** enabled by default
- **Security headers** (XSS, Content-Type, etc.)
- **Rate limiting** on API endpoints
- **Docker non-root user** for container security
- **Health checks** for monitoring
- **Security scanning** with Bandit and Safety

## 🚀 Deployment

### **Production Build**

```bash
# Build production image
docker build --target production -t my-django-app:latest .

# Test production image
docker run --rm -p 3000:3000 my-django-app:latest
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

**Celery worker issues:**
```bash
# Check Celery worker status
docker compose exec celery uv run celery -A config inspect ping

# Restart Celery services
docker compose restart celery celery-beat
```

**Permission issues:**
```bash
# Fix Django permissions
docker compose exec app chown -R djangouser:djangouser /app
```

**Tailwind CSS not building:**
```bash
# Rebuild CSS
docker compose exec app npm run build

# Check Node.js dependencies
docker compose exec app npm install
```

## 📚 Documentation

- [Development Guide](./docs/DEVELOPMENT.md) - Advanced development workflows
- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Celery Documentation](https://docs.celeryq.dev/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Docker Documentation](https://docs.docker.com/)

## 📄 License

This template is open-sourced software licensed under the [MIT license](LICENSE).

---

**Happy coding with Django! 🚀** 