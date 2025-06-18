# 🏗️ Architecture Guide - Sinatra API Template

## 🎯 System Overview

This Sinatra API template follows a lightweight, modular architecture designed for building fast, scalable JSON APIs and microservices. The system emphasizes simplicity, testability, and maintainability while providing production-ready features.

## 📐 Design Principles

### **1. Separation of Concerns**
- Controllers handle HTTP requests/responses
- Models manage data persistence and validation
- Services contain business logic
- Serializers format API responses

### **2. Dependency Injection**
- External dependencies injected through configuration
- Easy to mock and test
- Environment-specific configurations

### **3. Stateless Design**
- JWT-based authentication (no server-side sessions)
- Horizontally scalable
- Database stores all persistent state

### **4. API-First Approach**
- JSON responses by default
- RESTful resource design
- Versioned API endpoints

## 🏛️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │────│      Nginx      │
│   (Production)  │    │   (Reverse Proxy)│
└─────────────────┘    └─────────────────┘
                                │
                    ┌─────────────────┐
                    │  Sinatra API    │
                    │  (Ruby/Rack)    │
                    └─────────────────┘
                                │
                    ┌─────────────────┐
                    │   Controllers   │
                    │    (HTTP)       │
                    └─────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
┌─────────────┐        ┌─────────────┐        ┌─────────────┐
│   Models    │        │  Services   │        │ Serializers │
│(Sequel ORM) │        │(Logic Layer)│        │(JSON Format)│
└─────────────┘        └─────────────┘        └─────────────┘
        │                       │                       │
┌─────────────┐        ┌─────────────┐        ┌─────────────┐
│ PostgreSQL  │        │   Redis     │        │  External   │
│ (Database)  │        │  (Cache)    │        │   APIs      │
└─────────────┘        └─────────────┘        └─────────────┘
```

## 🔧 Application Layers

### **1. HTTP Layer (Sinatra Application)**
```ruby
# config/application.rb
class Application < Sinatra::Base
  # Route definitions
  # Middleware configuration
  # Error handling
  # CORS setup
end
```

**Responsibilities:**
- HTTP request routing
- Middleware orchestration
- Error handling and responses
- CORS and security headers

### **2. Controller Layer**
```ruby
# app/controllers/base_controller.rb
class BaseController
  # Common functionality
  # Authentication helpers
  # Response formatting
  # Parameter validation
end
```

**Responsibilities:**
- Request parameter extraction
- Authentication/authorization
- Response formatting
- HTTP status management

### **3. Service Layer**
```ruby
# app/services/user_service.rb
class UserService
  def self.create_user(params)
    # Business logic
    # Data validation
    # Transaction management
  end
end
```

**Responsibilities:**
- Business logic implementation
- Complex data operations
- External API integration
- Background job coordination

### **4. Model Layer (Sequel ORM)**
```ruby
# app/models/user.rb
class User < Sequel::Model
  # Data validation
  # Associations
  # Callbacks
  # Query methods
end
```

**Responsibilities:**
- Data persistence
- Model validation
- Database relationships
- Query optimization

### **5. Serialization Layer**
```ruby
# app/serializers/user_serializer.rb
class UserSerializer
  def self.serialize(user)
    # Response formatting
    # Data transformation
    # Security filtering
  end
end
```

**Responsibilities:**
- API response formatting
- Data transformation
- Sensitive data filtering
- Nested resource handling

## 🗄️ Database Design

### **Entity Relationship Overview**
```
Users (Primary Entity)
├── id (Primary Key)
├── email (Unique Index)
├── password_digest
├── first_name
├── last_name
├── role
├── active (Boolean)
├── created_at
└── updated_at

Posts (Example Extension)
├── id (Primary Key)
├── user_id (Foreign Key → Users.id)
├── title
├── content
├── published (Boolean)
├── created_at
└── updated_at
```

### **Database Patterns**

**1. Timestamps Pattern**
```ruby
class User < Sequel::Model
  plugin :timestamps, update_on_create: true
end
```

**2. Validation Pattern**
```ruby
def validate
  super
  validates_presence [:email, :password_digest]
  validates_unique :email
  validates_format(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email)
end
```

**3. Association Pattern**
```ruby
class User < Sequel::Model
  one_to_many :posts
end

class Post < Sequel::Model
  many_to_one :user
end
```

## 🔐 Authentication Architecture

### **JWT Token Flow**
```
1. User Login
   POST /api/v1/auth/login
   { email: "user@example.com", password: "secret" }
   
2. Server Validation
   - Verify credentials
   - Generate JWT token
   - Return token + user data
   
3. Client Storage
   - Store token (localStorage/memory)
   - Include in subsequent requests
   
4. Request Authentication
   Authorization: Bearer <jwt-token>
   
5. Server Validation
   - Decode JWT token
   - Verify signature
   - Extract user information
```

### **JWT Structure**
```ruby
# Payload
{
  user_id: 123,
  email: "user@example.com",
  exp: 1640995200  # Expiration timestamp
}

# Token Generation
JWT.encode(payload, ENV['JWT_SECRET'], 'HS256')

# Token Verification
JWT.decode(token, ENV['JWT_SECRET'], true, algorithm: 'HS256')
```

## 🔄 Request/Response Flow

### **Typical API Request Flow**
```
1. HTTP Request
   ├── Route Matching (Sinatra)
   ├── Middleware Processing
   │   ├── CORS Headers
   │   ├── JSON Parsing
   │   └── Authentication
   └── Controller Action

2. Controller Processing
   ├── Parameter Extraction
   ├── Authentication Check
   ├── Service Layer Call
   └── Response Formatting

3. Service Layer
   ├── Business Logic
   ├── Data Validation
   ├── Model Operations
   └── Result Return

4. Model Layer
   ├── Database Query
   ├── Data Validation
   ├── Persistence
   └── Response

5. Response Generation
   ├── Serialization
   ├── JSON Formatting
   └── HTTP Response
```

### **Example Request Flow**
```
POST /api/v1/users
{
  "email": "user@example.com",
  "password": "secret123",
  "first_name": "John",
  "last_name": "Doe"
}

Flow:
1. Sinatra routes to UsersController#create
2. Controller validates JSON and authentication
3. Service processes business logic
4. Model creates user record
5. Serializer formats response
6. JSON response returned

Response:
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "id": 123,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

## ⚡ Performance Architecture

### **Caching Strategy**
```ruby
# Redis Caching Layers
┌─────────────────┐
│ Application     │ ←── In-memory variables
├─────────────────┤
│ Redis Cache     │ ←── Frequent queries, session data
├─────────────────┤
│ Database        │ ←── Persistent data
└─────────────────┘
```

### **Database Performance**
```ruby
# Connection Pooling
DB = Sequel.connect(DATABASE_URL,
  max_connections: 10,
  pool_timeout: 10,
  test: false
)

# Query Optimization
User.where(active: true)
    .where(Sequel.like(:email, '%@company.com'))
    .order(:created_at)
    .limit(50)
```

### **Background Processing**
```ruby
# Service Pattern for Heavy Operations
class DataProcessingService
  def self.process_async(data)
    # Queue background job
    ProcessingWorker.perform_async(data)
  end
end
```

## 🔒 Security Architecture

### **Security Layers**
```
1. Network Security
   ├── HTTPS/TLS encryption
   ├── Rate limiting
   └── CORS configuration

2. Application Security
   ├── JWT token validation
   ├── Input validation
   ├── SQL injection prevention
   └── XSS protection

3. Data Security
   ├── Password hashing (BCrypt)
   ├── Sensitive data filtering
   └── Database access control
```

### **Security Implementation**
```ruby
# Password Security
def password=(new_password)
  self.password_digest = BCrypt::Password.create(new_password)
end

# Input Validation
def validate
  validates_format(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email)
  validates_min_length 8, :password
end

# Response Security
def to_json_hash
  {
    id: id,
    email: email,
    # Never expose password_digest
    created_at: created_at
  }
end
```

## 🐳 Deployment Architecture

### **Docker Multi-Stage Build**
```dockerfile
# Development Stage
FROM ruby:3.2-alpine AS development
# Development dependencies
# Hot reload support

# Build Stage  
FROM development AS build
# Production dependencies only
# Asset compilation

# Production Stage
FROM ruby:3.2-alpine AS production
# Minimal runtime
# Security hardening
# Health checks
```

### **Container Orchestration**
```yaml
# docker-compose.yml
services:
  api:        # Main application
  db:         # PostgreSQL database
  redis:      # Cache and sessions
  nginx:      # Reverse proxy (production)
```

## 📊 Monitoring Architecture

### **Observability Stack**
```
Logs → Structured JSON → Log Aggregation
Metrics → Application Metrics → Monitoring
Traces → Request Tracing → Performance Analysis
Errors → Error Tracking → Alert System
```

### **Health Check System**
```ruby
get '/health' do
  checks = {
    database: check_database,
    redis: check_redis,
    external_apis: check_external_services
  }
  
  if checks.values.all?
    json status: 'ok', checks: checks
  else
    status 503
    json status: 'error', checks: checks
  end
end
```

## 🔧 Configuration Management

### **Environment-Based Configuration**
```ruby
# config/application.rb
configure :development do
  set :logging, true
  enable :reloader
end

configure :production do
  set :logging, false
  disable :show_exceptions
end

configure :test do
  set :database_url, ENV['TEST_DATABASE_URL']
end
```

### **Secret Management**
```ruby
# Environment Variables
JWT_SECRET=...           # Authentication
DATABASE_URL=...         # Database connection
REDIS_URL=...           # Cache connection
SENTRY_DSN=...          # Error tracking
```

## 🔄 Testing Architecture

### **Testing Pyramid**
```
┌─────────────────┐
│ Integration     │ ←── Full API testing
├─────────────────┤
│ Service Tests   │ ←── Business logic
├─────────────────┤
│ Model Tests     │ ←── Data validation
├─────────────────┤
│ Unit Tests      │ ←── Individual methods
└─────────────────┘
```

### **Test Organization**
```
spec/
├── controllers/     # API endpoint tests
├── models/         # Database model tests
├── services/       # Business logic tests
├── factories/      # Test data generation
└── support/        # Test helpers
```

## 📈 Scalability Considerations

### **Horizontal Scaling**
- Stateless application design
- Database connection pooling
- Redis for shared state
- Load balancer distribution

### **Vertical Scaling**
- Memory optimization
- Database index optimization
- Query performance tuning
- Background job processing

### **Database Scaling**
- Read replicas for queries
- Connection pooling
- Query optimization
- Caching strategies

## 🔮 Future Architecture Evolution

### **Microservices Migration Path**
1. **Modular Monolith** (Current)
   - Service layer separation
   - Clear boundaries
   - Shared database

2. **Database Per Service**
   - Separate databases
   - API communication
   - Event-driven updates

3. **Full Microservices**
   - Independent deployments
   - Service mesh
   - Distributed tracing

### **Technology Evolution**
- GraphQL API layer
- Event sourcing patterns
- CQRS implementation
- Serverless functions

## 🛠️ Development Patterns

### **Controller Pattern**
```ruby
class UsersController < BaseController
  def index(request, params)
    # 1. Authentication
    current_user = require_authentication!
    
    # 2. Parameter extraction
    pagination = pagination_params
    
    # 3. Service call
    users = UserService.list_users(pagination)
    
    # 4. Response formatting
    paginated_response(users, pagination)
  end
end
```

### **Service Pattern**
```ruby
class UserService
  def self.create_user(params)
    DB.transaction do
      user = User.create(params)
      send_welcome_email(user)
      log_user_creation(user)
      user
    end
  rescue => e
    handle_error(e)
    raise
  end
end
```

### **Error Handling Pattern**
```ruby
error Sequel::ValidationFailed do
  status 422
  json error: 'Validation failed', details: env['sinatra.error'].errors
end

error StandardError do
  if ENV['RACK_ENV'] == 'development'
    json error: env['sinatra.error'].message, backtrace: env['sinatra.error'].backtrace
  else
    json error: 'Internal server error'
  end
end
```

## 📋 Architecture Decisions

### **Why Sinatra over Rails?**
- **Lightweight**: Minimal overhead for API-only applications
- **Flexibility**: Full control over middleware stack
- **Performance**: Faster request/response cycle
- **Simplicity**: Easier to understand and maintain

### **Why Sequel over ActiveRecord?**
- **Thread Safety**: Better for concurrent requests
- **SQL Control**: Direct access to advanced SQL features
- **Performance**: More efficient query generation
- **Flexibility**: Plugin architecture for extensions

### **Why JWT over Sessions?**
- **Stateless**: Horizontally scalable
- **Cross-Domain**: Works across different domains
- **Mobile-Friendly**: Easy to implement in mobile apps
- **Microservices**: Shared authentication across services

### **Why PostgreSQL over MySQL?**
- **JSON Support**: Native JSON data types
- **Concurrency**: Better handling of concurrent writes
- **Standards**: Full SQL standard compliance
- **Extensions**: PostGIS, full-text search, etc.

---

**🎯 This architecture balances simplicity with scalability, providing a solid foundation for API development while maintaining flexibility for future growth.** 