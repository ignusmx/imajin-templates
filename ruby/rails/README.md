# Rails 8.0.2 Docker Template

A modern, production-ready Rails application template with Docker, PostgreSQL, and Tailwind CSS v4.

## 🚀 Features

- **Rails 8.0.2** - Latest stable Rails version
- **Ruby 3.2.8** - Modern Ruby version
- **PostgreSQL 15** - Reliable database
- **Tailwind CSS v4** - Modern utility-first CSS framework
- **Docker & Docker Compose** - Containerized development and deployment
- **Watchman** - Fast file watching for development
- **Development-optimized** - Hot reloading, file watching, and debugging support

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or higher)

## 🛠 Quick Start

### 1. Clone or Use This Template

```bash
# Clone this repository
git clone <your-repo-url>
cd rails-docker-template

# Or use as GitHub template
# Click "Use this template" button on GitHub
```

### 2. Start the Application

```bash
# Build and start all services
docker compose up

# Or run in background
docker compose up -d
```

### 3. Access Your Application

- **Web Application**: http://localhost:3000
- **PostgreSQL Database**: localhost:5432

## 🏗 Project Structure

```
├── app/                    # Rails application code
│   ├── assets/
│   │   ├── stylesheets/   # Traditional CSS files
│   │   └── tailwind/      # Tailwind CSS source
│   ├── controllers/
│   ├── models/
│   └── views/
├── bin/                   # Executable scripts
│   ├── css-watch         # Custom Tailwind watcher script
│   └── docker-entrypoint # Docker container entrypoint
├── config/               # Rails configuration
│   └── database.yml     # Database configuration
├── db/                   # Database files
├── Dockerfile           # Docker image definition
├── docker-compose.yml   # Multi-container Docker application
├── Gemfile              # Ruby dependencies
├── Procfile.dev         # Development process configuration
└── README.md           # This file
```

## 🐳 Docker Configuration

### Services

- **web**: Rails application server (Puma)
- **db**: PostgreSQL 15 database

### Environment Variables

The application uses the following environment variables:

- `DATABASE_HOST`: PostgreSQL host (default: `db`)
- `DATABASE_USERNAME`: Database username (default: `postgres`)
- `DATABASE_PASSWORD`: Database password (default: `password`)
- `RAILS_ENV`: Rails environment (default: `development`)

## 💻 Development Commands

### Basic Operations

```bash
# Start the application
docker compose up

# Start in background
docker compose up -d

# Stop the application
docker compose down

# View logs
docker compose logs -f web
```

### Database Operations

```bash
# Create database
docker compose run --rm web bin/rails db:create

# Run migrations
docker compose run --rm web bin/rails db:migrate

# Seed database
docker compose run --rm web bin/rails db:seed

# Reset database
docker compose run --rm web bin/rails db:reset

# Open Rails console
docker compose run --rm web bin/rails console
```

### Bundle Operations

```bash
# Install gems
docker compose run --rm web bundle install

# Update gems
docker compose run --rm web bundle update

# Add a new gem (after updating Gemfile)
docker compose build web
```

### Rails Generators

```bash
# Generate a controller
docker compose run --rm web bin/rails generate controller Pages home

# Generate a model
docker compose run --rm web bin/rails generate model User name:string email:string

# Generate a migration
docker compose run --rm web bin/rails generate migration AddIndexToUsers email:index
```

### Testing

```bash
# Run all tests
docker compose run --rm web bin/rails test

# Run specific test file
docker compose run --rm web bin/rails test test/models/user_test.rb

# Run system tests
docker compose run --rm web bin/rails test:system
```

## 🎨 Tailwind CSS

This template includes Tailwind CSS v4 with automatic building and watching.

### Tailwind Configuration

- **Source file**: `app/assets/tailwind/application.css`
- **Output file**: `app/assets/builds/tailwind.css`
- **Watcher**: Automatically builds CSS on container start

### Manual Tailwind Commands

```bash
# Build Tailwind CSS
docker compose run --rm web bin/rails tailwindcss:build

# Watch for changes (manual)
docker compose run --rm web bin/rails tailwindcss:watch
```

## 🗄 Database

### PostgreSQL Configuration

- **Version**: PostgreSQL 15
- **Host**: `db` (within Docker network)
- **Port**: 5432
- **Database**: `app_development`
- **Username**: `postgres`
- **Password**: `password`

### Connecting to Database

```bash
# Using Rails console
docker compose run --rm web bin/rails console

# Direct PostgreSQL connection
docker compose exec db psql -U postgres -d app_development
```

## 🔧 Customization

### Adding New Gems

1. Add gem to `Gemfile`
2. Rebuild the Docker image:
   ```bash
   docker compose build web
   ```

### Environment Variables

Create a `.env` file in the project root:

```env
DATABASE_PASSWORD=your_secure_password
RAILS_MASTER_KEY=your_master_key
```

### Custom Scripts

Add executable scripts to the `bin/` directory and rebuild the image.

## 🚀 Production Deployment

### Building for Production

```bash
# Build production image
docker build -t your-app:latest .

# Or use docker-compose with production override
docker compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### Environment Variables for Production

Set these environment variables in your production environment:

- `RAILS_ENV=production`
- `RAILS_MASTER_KEY=<your-secret-key>`
- `DATABASE_URL=<your-production-database-url>`
- `SECRET_KEY_BASE=<your-secret-key-base>`

## 🛠 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker compose logs web

# Rebuild image
docker compose build --no-cache web
```

#### Database Connection Issues
```bash
# Ensure database is running
docker compose up db

# Check database logs
docker compose logs db

# Reset database
docker compose run --rm web bin/rails db:reset
```

#### Permission Issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Rebuild with clean cache
docker compose build --no-cache
```

#### Gem Installation Issues
```bash
# Clear bundler cache
docker compose run --rm web bundle clean --force

# Rebuild image
docker compose build --no-cache web
```

### Performance Optimization

#### For Development
- Use Docker volumes for faster file sync
- Enable BuildKit for faster builds:
  ```bash
  export DOCKER_BUILDKIT=1
  export COMPOSE_DOCKER_CLI_BUILD=1
  ```

#### For Production
- Use multi-stage builds
- Optimize Dockerfile layers
- Use specific gem versions

## 📚 Additional Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [Rails 8.0.2 Release Notes](https://rubyonrails.org/2025/3/12/Rails-Version-8-0-2-has-been-released)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Template Information

- **Rails Version**: 8.0.2
- **Ruby Version**: 3.2.8
- **PostgreSQL Version**: 15
- **Tailwind CSS Version**: 4.x
- **Docker**: Multi-stage build optimized for development

---

**Happy coding!** 🎉

For questions or issues, please open an issue in the repository.
