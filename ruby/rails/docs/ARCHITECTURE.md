# Architecture Documentation

This document describes the architecture and design decisions for the Rails Docker Template.

## Overview

The Rails Docker Template is built with a Docker-first approach, prioritizing development experience, production readiness, and modern Rails best practices.

## Technology Stack

### Core Technologies

- **Ruby 3.2.8** - Latest stable Ruby with performance improvements
- **Rails 8.0.2** - Latest Rails with enhanced performance and security
- **PostgreSQL 15** - Primary database with Alpine Linux for lightweight containers
- **Redis 7** - Caching, session storage, and background job queue
- **Alpine Linux** - Lightweight base images for all containers

### Development Tools

- **Docker & Docker Compose** - Containerized development environment
- **Watchman** - Fast file watching for hot reload
- **Puma** - High-performance web server
- **Tailwind CSS v4** - Utility-first CSS framework

### Code Quality & Testing

- **RSpec** - Behavior-driven development testing framework
- **Factory Bot** - Test data generation
- **Rubocop** - Ruby code style and linting
- **Brakeman** - Security vulnerability scanner
- **Bullet** - N+1 query detection
- **SimpleCov** - Code coverage analysis

## Architecture Patterns

### Layered Architecture

```
┌─────────────────────────────────────┐
│              Presentation           │  (Controllers, Views, JSON APIs)
├─────────────────────────────────────┤
│              Application            │  (Services, Use Cases)
├─────────────────────────────────────┤
│              Domain                 │  (Models, Business Logic)
├─────────────────────────────────────┤
│              Infrastructure         │  (Database, Redis, External APIs)
└─────────────────────────────────────┘
```

### Service Objects

Complex business logic is extracted into service objects to maintain single responsibility and testability:

```ruby
# app/services/user_registration_service.rb
class UserRegistrationService
  def initialize(params)
    @params = params
  end

  def perform
    ActiveRecord::Base.transaction do
      create_user
      send_welcome_email
      track_registration
    end
  end

  private

  def create_user
    # User creation logic
  end
end
```

### Repository Pattern (Optional)

For complex data access patterns, repository objects can be used:

```ruby
# app/repositories/user_repository.rb
class UserRepository
  def find_active_users
    User.where(active: true)
  end

  def find_by_email(email)
    User.find_by(email: email)
  end
end
```

## Container Architecture

### Multi-Stage Docker Build

```dockerfile
FROM ruby:3.2.8-alpine as base
# Base configuration

FROM base as development
# Development-specific setup

FROM base as build
# Build stage for production

FROM base as production
# Final production image
```

### Service Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Nginx       │    │   Rails App     │    │   Background    │
│  (Load Balancer)│◄──►│   (Web Server) │    │   Jobs (Sidekiq)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                        ┌─────────────────┐    ┌─────────────────┐
                        │   PostgreSQL    │    │     Redis       │
                        │   (Database)    │    │  (Cache/Queue)  │
                        └─────────────────┘    └─────────────────┘
```

## Database Design

### Connection Management

- **Connection Pooling**: Managed by ActiveRecord
- **Read/Write Splitting**: Optional for high-traffic applications
- **Migration Strategy**: Zero-downtime migrations with strong_migrations gem

### Schema Design Principles

1. **Normalized Data Structure** - Reduce redundancy
2. **Proper Indexing** - Performance optimization
3. **Foreign Key Constraints** - Data integrity
4. **Soft Deletes** - Data retention and recovery

```ruby
# Example model with soft delete
class User < ApplicationRecord
  acts_as_paranoid
  
  has_many :posts, dependent: :destroy
  validates :email, presence: true, uniqueness: true
  
  scope :active, -> { where(active: true) }
end
```

## Caching Strategy

### Multi-Level Caching

1. **Application Cache** - Rails.cache with Redis backend
2. **Database Query Cache** - ActiveRecord built-in caching
3. **HTTP Cache** - Conditional requests and ETags
4. **CDN Cache** - Static assets and API responses

```ruby
# Example caching implementation
class PostsController < ApplicationController
  def index
    @posts = Rails.cache.fetch("posts/#{cache_key}", expires_in: 1.hour) do
      Post.published.includes(:author).limit(10)
    end
  end

  private

  def cache_key
    [current_user&.id, Post.published.maximum(:updated_at)].compact.join('/')
  end
end
```

## Security Architecture

### Security Layers

1. **Network Security**
   - TLS/SSL encryption
   - Firewall configuration
   - VPN access for sensitive operations

2. **Application Security**
   - CSRF protection
   - SQL injection prevention
   - XSS protection
   - Content Security Policy

3. **Authentication & Authorization**
   - JWT tokens or session-based auth
   - Role-based access control
   - API key management

4. **Data Security**
   - Database encryption at rest
   - Sensitive data masking
   - Audit logging

### Security Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Force SSL
  config.force_ssl = true
  
  # Secure headers
  config.ssl_options = {
    secure_cookies: true,
    hsts: { expires: 1.year }
  }
  
  # Content Security Policy
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.script_src  :self, 'sha256-xyz'
  end
end
```

## Performance Considerations

### Application Performance

1. **Database Query Optimization**
   - N+1 query prevention with includes/joins
   - Query analysis with bullet gem
   - Database indexing strategy

2. **Memory Management**
   - Object allocation reduction
   - Garbage collection tuning
   - Memory profiling with memory_profiler

3. **Background Processing**
   - Sidekiq for heavy operations
   - Job prioritization and retry logic
   - Dead job monitoring

### Infrastructure Performance

1. **Container Optimization**
   - Multi-stage builds for smaller images
   - Layer caching optimization
   - Resource limit configuration

2. **Database Performance**
   - Connection pooling
   - Read replicas for scaling
   - Regular maintenance tasks

## Monitoring and Observability

### Application Monitoring

```ruby
# Health check endpoint
class HealthController < ApplicationController
  def show
    checks = {
      database: database_check,
      redis: redis_check,
      app: app_check
    }
    
    if checks.values.all?
      render json: { status: 'ok', checks: checks }
    else
      render json: { status: 'error', checks: checks }, status: 503
    end
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute('SELECT 1')
    'ok'
  rescue
    'error'
  end
end
```

### Logging Strategy

```ruby
# config/application.rb
config.log_formatter = ::Logger::Formatter.new
config.logger = ActiveSupport::Logger.new(STDOUT)
config.log_level = :info

# Structured logging
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new
```

## API Design

### RESTful API Structure

```
GET    /api/v1/users           # List users
POST   /api/v1/users           # Create user
GET    /api/v1/users/:id       # Show user
PUT    /api/v1/users/:id       # Update user
DELETE /api/v1/users/:id       # Delete user
```

### API Versioning Strategy

- **URL Versioning**: `/api/v1/` for backward compatibility
- **Header Versioning**: `Accept: application/vnd.api+json;version=1`
- **Content Negotiation**: Support JSON and JSON:API formats

### Error Handling

```ruby
class ApiController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_errors

  private

  def render_not_found
    render json: { error: 'Resource not found' }, status: 404
  end

  def render_validation_errors(exception)
    render json: { 
      error: 'Validation failed',
      details: exception.record.errors.full_messages
    }, status: 422
  end
end
```

## Development Workflow

### Git Workflow

1. **Feature Branches** - Isolated development
2. **Pull Request Reviews** - Code quality assurance
3. **Automated Testing** - CI/CD pipeline
4. **Semantic Versioning** - Release management

### Testing Strategy

```ruby
# RSpec configuration
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include Shoulda::Matchers::ActiveModel
  config.include Shoulda::Matchers::ActiveRecord
end

# Example test structure
describe UsersController do
  describe 'GET #index' do
    it 'returns successful response' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
```

## Deployment Architecture

### Environment Separation

- **Development**: Docker Compose with volume mounts
- **Staging**: Production-like environment for testing
- **Production**: Optimized containers with external services

### Infrastructure as Code

```yaml
# docker-compose.prod.yml
version: '3.9'
services:
  app:
    image: rails-app:latest
    environment:
      - RAILS_ENV=production
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

## Scalability Considerations

### Horizontal Scaling

1. **Stateless Application Design**
2. **Load Balancer Configuration**
3. **Database Read Replicas**
4. **Distributed Caching**

### Vertical Scaling

1. **Resource Optimization**
2. **Memory Management**
3. **CPU Utilization**
4. **Database Tuning**

## Future Considerations

### Potential Enhancements

1. **Microservices Architecture** - Service decomposition
2. **Event-Driven Architecture** - Pub/sub messaging
3. **GraphQL API** - Flexible data fetching
4. **Container Orchestration** - Kubernetes deployment

### Technology Evolution

- **Ruby/Rails Updates** - Regular framework upgrades
- **Database Technologies** - NoSQL integration options
- **Caching Solutions** - Advanced caching strategies
- **Monitoring Tools** - Enhanced observability

## Decision Records

### ADR-001: Docker-First Development

**Status**: Accepted

**Context**: Need for consistent development environment across team members.

**Decision**: Use Docker for all development activities.

**Consequences**: 
- Positive: Consistent environment, easy setup
- Negative: Learning curve for Docker-unfamiliar developers

### ADR-002: Alpine Linux Base Images

**Status**: Accepted

**Context**: Need to minimize container image sizes and security surface.

**Decision**: Use Alpine Linux for all base images.

**Consequences**:
- Positive: Smaller images, faster deployments
- Negative: Potential compatibility issues with some gems

### ADR-003: PostgreSQL as Primary Database

**Status**: Accepted

**Context**: Need for robust, ACID-compliant database with JSON support.

**Decision**: Use PostgreSQL 15 as the primary database.

**Consequences**:
- Positive: Strong consistency, JSON support, excellent Rails integration
- Negative: More resource-intensive than lighter alternatives 