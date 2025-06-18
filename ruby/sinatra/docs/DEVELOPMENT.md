# 🛠️ Development Guide - Sinatra API Template

## 🎯 Development Environment Setup

### **Prerequisites**
- Docker & Docker Compose
- Git
- Code editor (VS Code recommended)

### **Quick Setup**
```bash
git clone <your-repo>
cd sinatra-api
./scripts/setup.sh && ./scripts/dev.sh
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
│   │   └── user.rb
│   ├── services/           # Business logic services
│   ├── serializers/        # JSON response serializers
│   └── validators/         # Input validation
├── config/
│   ├── application.rb      # Main application configuration
│   ├── database.rb         # Database configuration
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
│   ├── factories/
│   └── spec_helper.rb
├── scripts/               # Development scripts
│   ├── setup.sh
│   ├── dev.sh
│   └── test.sh
└── docs/                  # Documentation
    ├── DEVELOPMENT.md     # This file
    ├── DEPLOYMENT.md      # Production deployment
    └── ARCHITECTURE.md    # Design decisions
```

## 🐳 Docker Development

### **Services**
- **api**: Main Sinatra application (port 3000)
- **db**: PostgreSQL database (port 5432)  
- **redis**: Redis cache (port 6379)

### **Common Commands**
```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f api

# Access API container
docker compose exec api bash

# Run commands in container
docker compose exec api bundle exec rake db:migrate
docker compose exec api bundle exec rspec

# Stop all services
docker compose down

# Reset everything
docker compose down -v && docker compose up --build
```

## 🗄️ Database Development

### **Migrations**
```bash
# Create new migration
bundle exec rake db:create_migration[create_posts]

# Run migrations
bundle exec rake db:migrate

# Rollback last migration
bundle exec rake db:rollback

# Check migration status
bundle exec rake db:status
```

### **Database Management**
```bash
# Create database
bundle exec rake db:create

# Drop database
bundle exec rake db:drop

# Reset database (drop, create, migrate, seed)
bundle exec rake db:reset

# Seed with sample data
bundle exec rake db:seed
```

### **Model Patterns**
```ruby
class Post < Sequel::Model
  plugin :validation_helpers
  plugin :json_serializer
  plugin :timestamps, update_on_create: true
  
  many_to_one :user
  
  def validate
    super
    validates_presence [:title, :content, :user_id]
    validates_min_length 10, :content
  end
  
  def to_json_hash
    {
      id: id,
      title: title,
      content: content,
      user_id: user_id,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
```

## 🎮 Controller Development

### **Controller Patterns**
```ruby
class PostsController < BaseController
  def index(request, params)
    @request = request
    @params = params
    
    current_user = require_authentication!
    pagination = pagination_params
    
    posts = Post.where(user: current_user)
                .limit(pagination[:per_page])
                .offset((pagination[:page] - 1) * pagination[:per_page])
    
    paginated_response(
      posts.map(&:to_json_hash),
      page: pagination[:page],
      per_page: pagination[:per_page],
      total: Post.where(user: current_user).count
    )
  end
end
```

### **Authentication**
```ruby
# In your controller
current_user = require_authentication!  # Throws 401 if no valid token
user = current_user_from_token          # Returns user or nil
```

### **Response Helpers**
```ruby
# Success responses
success_response(data, message: 'Success', status: 200)

# Error responses
error_response('Error message', details: {}, status: 400)

# Paginated responses
paginated_response(collection, page: 1, per_page: 20, total: 100)
```

## 🧪 Testing Development

### **Test Structure**
```
spec/
├── controllers/           # API endpoint tests
├── models/               # Model validation tests
├── services/             # Business logic tests
├── factories/            # Test data factories
├── support/              # Test helpers
└── spec_helper.rb        # Test configuration
```

### **Writing Tests**
```ruby
# Controller test example
RSpec.describe 'Posts API', type: :request do
  let(:user) { create(:user) }
  
  describe 'GET /api/v1/posts' do
    it 'returns user posts' do
      create_list(:post, 3, user: user)
      
      get '/api/v1/posts', {}, auth_headers(user)
      
      expect_success_response
      expect(json_response['data'].length).to eq(3)
    end
  end
end

# Model test example
RSpec.describe User do
  describe 'validations' do
    it 'requires email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end
end
```

### **Test Helpers**
```ruby
# Authentication helpers
auth_headers(user)              # Returns authorization headers
generate_jwt_token(user)        # Generates JWT token

# API helpers
api_post('/path', data, headers)
api_put('/path', data, headers)
expect_success_response(200)
expect_error_response(400, 'Error message')

# Response helpers
json_response                   # Parsed JSON response
```

### **Running Tests**
```bash
# All tests
bundle exec rspec

# Specific tests
bundle exec rspec spec/controllers/users_controller_spec.rb
bundle exec rspec spec/models/user_spec.rb

# With coverage
COVERAGE=true bundle exec rspec

# Tagged tests
bundle exec rspec -t auth
bundle exec rspec -t integration
```

## 🔧 Code Quality

### **Linting & Formatting**
```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Security audit
bundle exec brakeman

# Dependency audit
bundle exec bundle-audit check --update
```

### **Pre-commit Hooks**
```bash
# Install hooks
bundle exec overcommit --install

# Run hooks manually
bundle exec overcommit --run
```

## 🚀 API Development

### **Adding New Endpoints**

1. **Create Controller**:
```ruby
# app/controllers/posts_controller.rb
class PostsController < BaseController
  def index(request, params)
    # Implementation
  end
end
```

2. **Add Routes**:
```ruby
# config/application.rb
namespace '/posts' do
  before { @current_user = authenticate_request! }
  
  get '' do
    PostsController.new.index(request, params)
  end
end
```

3. **Add Tests**:
```ruby
# spec/controllers/posts_controller_spec.rb
RSpec.describe 'Posts API', type: :request do
  # Test cases
end
```

### **Authentication Flow**
```ruby
# Login
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}

# Response
{
  "success": true,
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {...},
    "expires_in": 86400
  }
}

# Use token in requests
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

## 🔄 Development Workflow

### **Daily Development**
1. Pull latest changes: `git pull`
2. Start development: `./scripts/dev.sh`
3. Make changes
4. Run tests: `./scripts/test.sh`
5. Commit and push

### **Adding Features**
1. Create feature branch: `git checkout -b feature/new-feature`
2. Write tests first (TDD)
3. Implement feature
4. Ensure tests pass
5. Create pull request

### **Database Changes**
1. Create migration: `bundle exec rake db:create_migration[name]`
2. Edit migration file
3. Run migration: `bundle exec rake db:migrate`
4. Update seeds if needed
5. Test migration rollback

## 📊 Monitoring & Debugging

### **Logging**
```ruby
# Application logs
logger.info "Processing request: #{request.path}"
logger.error "Error occurred: #{e.message}"

# View logs
docker compose logs -f api
```

### **Debugging**
```ruby
# Add debugging
require 'pry'
binding.pry  # Breakpoint

# Debug in container
docker compose exec api bash
```

### **Performance Monitoring**
```ruby
# Database query logging (development)
DB.loggers << Logger.new($stdout)

# Request timing
before do
  @start_time = Time.now
end

after do
  duration = Time.now - @start_time
  logger.info "Request completed in #{duration}s"
end
```

## 🔒 Security Best Practices

### **Authentication**
- Use strong JWT secrets in production
- Set appropriate token expiration times
- Validate all user inputs
- Use HTTPS in production

### **Database**
- Use parameterized queries (Sequel handles this)
- Validate data types and constraints
- Don't expose sensitive fields in API responses

### **CORS**
- Configure appropriate origins
- Don't use wildcard (*) in production
- Set appropriate headers

## 🛠️ Troubleshooting

### **Common Issues**

**Database Connection Errors**
```bash
# Check if PostgreSQL is running
docker compose ps db

# Reset database
docker compose down -v
./scripts/setup.sh
```

**JWT Token Issues**
```bash
# Check JWT secret is set
echo $JWT_SECRET

# Verify token generation
bundle exec ruby -e "require './config/application'; puts JWT.encode({test: true}, ENV['JWT_SECRET'], 'HS256')"
```

**Port Already in Use**
```bash
# Find process using port
lsof -ti:3000

# Kill process
kill -9 $(lsof -ti:3000)
```

**Bundle Install Issues**
```bash
# Clear bundle cache
docker compose down
docker volume rm $(docker compose config --services | xargs -I {} echo "$(basename $PWD)_{}_bundle_cache")
docker compose up --build
```

## 📝 Tips & Best Practices

1. **Keep controllers thin** - Move business logic to services
2. **Use factories in tests** - Don't create records manually
3. **Write descriptive test names** - Tests should read like documentation
4. **Validate early** - Check inputs before processing
5. **Use transactions** - For multi-step database operations
6. **Log important events** - But don't over-log
7. **Keep migrations simple** - One change per migration
8. **Use environment variables** - Never hardcode configuration 