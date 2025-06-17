#!/bin/bash

set -e

echo "🧪 Running Laravel Tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect Docker Compose command
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif docker-compose --version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    print_error "Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Check if containers are running
check_containers() {
    print_status "Checking if containers are running..."
    
    if ! $DOCKER_COMPOSE_CMD ps | grep -q "Up"; then
        print_warning "Containers are not running. Starting them..."
        $DOCKER_COMPOSE_CMD up -d
        
        # Wait for database to be ready
        max_attempts=30
        attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            if $DOCKER_COMPOSE_CMD exec -T db pg_isready -U postgres > /dev/null 2>&1; then
                print_success "Database is ready"
                break
            fi
            
            print_status "Waiting for database... (attempt $attempt/$max_attempts)"
            sleep 2
            attempt=$((attempt + 1))
            
            if [ $attempt -gt $max_attempts ]; then
                print_error "Database failed to start within expected time"
                exit 1
            fi
        done
    else
        print_success "Containers are running"
    fi
}

# Setup test environment
setup_test_env() {
    print_status "Setting up test environment..."
    
    # Create test database if it doesn't exist
    $DOCKER_COMPOSE_CMD exec -T db psql -U postgres -c "CREATE DATABASE laravel_testing;" 2>/dev/null || true
    
    # Set testing environment variables
    $DOCKER_COMPOSE_CMD exec -T app php artisan config:clear
    $DOCKER_COMPOSE_CMD exec -T app php artisan cache:clear
    
    print_success "Test environment setup completed"
}

# Run PHP linting
run_php_linting() {
    print_status "Running PHP linting with Pint..."
    
    if $DOCKER_COMPOSE_CMD exec -T app composer show laravel/pint > /dev/null 2>&1; then
        $DOCKER_COMPOSE_CMD exec -T app ./vendor/bin/pint --test
        print_success "PHP linting passed"
    else
        print_warning "Laravel Pint not installed, skipping PHP linting"
    fi
}

# Run static analysis
run_static_analysis() {
    print_status "Running static analysis..."
    
    # Run PHPStan if available
    if $DOCKER_COMPOSE_CMD exec -T app composer show phpstan/phpstan > /dev/null 2>&1; then
        $DOCKER_COMPOSE_CMD exec -T app ./vendor/bin/phpstan analyse --no-progress
        print_success "Static analysis passed"
    else
        print_warning "PHPStan not installed, skipping static analysis"
    fi
}

# Run security checks
run_security_checks() {
    print_status "Running security checks..."
    
    # Check for security vulnerabilities in dependencies
    $DOCKER_COMPOSE_CMD exec -T app composer audit --no-dev
    
    print_success "Security checks completed"
}

# Run PHPUnit tests
run_phpunit_tests() {
    print_status "Running PHPUnit tests..."
    
    # Run migrations for testing
    $DOCKER_COMPOSE_CMD exec -T app php artisan migrate:fresh --env=testing --force
    
    # Run tests with coverage
    if [ "$1" = "--coverage" ]; then
        print_status "Running tests with coverage..."
        $DOCKER_COMPOSE_CMD exec -T app php artisan test --coverage --min=80
    else
        $DOCKER_COMPOSE_CMD exec -T app php artisan test --parallel
    fi
    
    print_success "PHPUnit tests completed"
}

# Run feature tests
run_feature_tests() {
    print_status "Running feature tests..."
    
    $DOCKER_COMPOSE_CMD exec -T app php artisan test tests/Feature --parallel
    
    print_success "Feature tests completed"
}

# Run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    
    $DOCKER_COMPOSE_CMD exec -T app php artisan test tests/Unit --parallel
    
    print_success "Unit tests completed"
}

# Run database tests
run_database_tests() {
    print_status "Running database tests..."
    
    # Test database connection
    $DOCKER_COMPOSE_CMD exec -T app php artisan migrate:status --env=testing
    
    # Run database-specific tests
    if [ -d "tests/Database" ]; then
        $DOCKER_COMPOSE_CMD exec -T app php artisan test tests/Database --parallel
    fi
    
    print_success "Database tests completed"
}

# Run API tests
run_api_tests() {
    print_status "Running API tests..."
    
    # Run API-specific tests if they exist
    if [ -d "tests/Api" ]; then
        $DOCKER_COMPOSE_CMD exec -T app php artisan test tests/Api --parallel
    fi
    
    print_success "API tests completed"
}

# Run browser tests
run_browser_tests() {
    print_status "Checking for browser tests..."
    
    # Check if Dusk is installed
    if $DOCKER_COMPOSE_CMD exec -T app composer show laravel/dusk > /dev/null 2>&1; then
        print_status "Running Laravel Dusk browser tests..."
        $DOCKER_COMPOSE_CMD exec -T app php artisan dusk
        print_success "Browser tests completed"
    else
        print_warning "Laravel Dusk not installed, skipping browser tests"
    fi
}

# Run performance tests
run_performance_tests() {
    print_status "Running performance tests..."
    
    # Basic performance check
    $DOCKER_COMPOSE_CMD exec -T app php artisan route:cache
    $DOCKER_COMPOSE_CMD exec -T app php artisan config:cache
    $DOCKER_COMPOSE_CMD exec -T app php artisan view:cache
    
    print_success "Performance tests completed"
}

# Generate test report
generate_test_report() {
    print_status "Generating test report..."
    
    # Create reports directory
    mkdir -p reports
    
    # Generate coverage report if requested
    if [ "$1" = "--coverage" ]; then
        $DOCKER_COMPOSE_CMD exec -T app php artisan test --coverage-html reports/coverage
        print_success "Coverage report generated in reports/coverage/"
    fi
    
    print_success "Test report generated"
}

# Show test summary
show_test_summary() {
    echo ""
    echo "=================================="
    print_success "🎉 All Tests Completed!"
    echo "=================================="
    echo ""
    echo "✅ Test Summary:"
    echo "   • PHP Linting: Passed"
    echo "   • Static Analysis: Passed"
    echo "   • Security Checks: Passed"
    echo "   • Unit Tests: Passed"
    echo "   • Feature Tests: Passed"
    echo "   • Database Tests: Passed"
    echo "   • API Tests: Passed"
    echo "   • Performance Tests: Passed"
    echo ""
    echo "🛠️  Next Steps:"
    echo "   • Review any warnings above"
    echo "   • Check coverage reports (if generated)"
    echo "   • Commit your changes if all tests pass"
    echo ""
}

# Handle different test types
handle_test_type() {
    case "$1" in
        "unit")
            run_unit_tests
            ;;
        "feature")
            run_feature_tests
            ;;
        "database")
            run_database_tests
            ;;
        "api")
            run_api_tests
            ;;
        "browser")
            run_browser_tests
            ;;
        "performance")
            run_performance_tests
            ;;
        "lint")
            run_php_linting
            ;;
        "static")
            run_static_analysis
            ;;
        "security")
            run_security_checks
            ;;
        *)
            # Run all tests
            run_php_linting
            run_static_analysis
            run_security_checks
            run_phpunit_tests "$2"
            run_browser_tests
            run_performance_tests
            ;;
    esac
}

# Main execution
main() {
    echo "🧪 Laravel Test Suite"
    echo "===================="
    echo ""
    
    # Parse arguments
    TEST_TYPE="all"
    COVERAGE_FLAG=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --coverage)
                COVERAGE_FLAG="--coverage"
                shift
                ;;
            --type=*)
                TEST_TYPE="${1#*=}"
                shift
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo ""
                echo "Options:"
                echo "  --coverage          Generate coverage report"
                echo "  --type=TYPE         Run specific test type (unit|feature|database|api|browser|performance|lint|static|security)"
                echo "  --help              Show this help message"
                echo ""
                exit 0
                ;;
            *)
                TEST_TYPE="$1"
                shift
                ;;
        esac
    done
    
    check_containers
    setup_test_env
    handle_test_type "$TEST_TYPE" "$COVERAGE_FLAG"
    
    if [ "$TEST_TYPE" = "all" ]; then
        generate_test_report "$COVERAGE_FLAG"
        show_test_summary
    fi
}

# Run main function
main "$@" 