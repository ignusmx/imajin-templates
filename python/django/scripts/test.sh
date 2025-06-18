#!/bin/bash

set -e

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

# Test type and options
TEST_TYPE=""
RUN_COVERAGE=false
VERBOSE=false

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            unit|integration|api|lint|format|security)
                TEST_TYPE="$1"
                shift
                ;;
            --coverage)
                RUN_COVERAGE=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help message
show_help() {
    echo "Django Testing Script"
    echo ""
    echo "Usage: $0 [TEST_TYPE] [OPTIONS]"
    echo ""
    echo "Test Types:"
    echo "  unit        Run unit tests only"
    echo "  integration Run integration tests only"
    echo "  api         Run API tests only"
    echo "  lint        Run linting checks"
    echo "  format      Run code formatting"
    echo "  security    Run security checks"
    echo "  (no type)   Run all tests"
    echo ""
    echo "Options:"
    echo "  --coverage  Generate test coverage report"
    echo "  --verbose   Verbose output"
    echo "  --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 unit --coverage    # Run unit tests with coverage"
    echo "  $0 lint              # Run linting only"
    echo "  $0 api --verbose     # Run API tests with verbose output"
}

# Check if application is running
check_services() {
    print_status "Checking if services are running..."
    
    if ! $DOCKER_COMPOSE_CMD ps | grep -q "Up"; then
        print_status "Starting services for testing..."
        $DOCKER_COMPOSE_CMD up -d
        
        # Wait for services to be ready
        sleep 10
        
        # Check database
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
    fi
}

# Run Django migrations for testing
prepare_test_db() {
    print_status "Preparing test database..."
    $DOCKER_COMPOSE_CMD exec -T app uv run python manage.py migrate --settings=config.settings.test
}

# Run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    
    local cmd="uv run python -m pytest tests/unit/ -v"
    
    if [ "$RUN_COVERAGE" = true ]; then
        cmd="$cmd --cov=apps --cov-report=html --cov-report=term-missing"
    fi
    
    if [ "$VERBOSE" = true ]; then
        cmd="$cmd -s"
    fi
    
    $DOCKER_COMPOSE_CMD exec -T app $cmd
}

# Run integration tests
run_integration_tests() {
    print_status "Running integration tests..."
    
    local cmd="uv run python -m pytest tests/integration/ -v"
    
    if [ "$RUN_COVERAGE" = true ]; then
        cmd="$cmd --cov=apps --cov-report=html --cov-report=term-missing"
    fi
    
    if [ "$VERBOSE" = true ]; then
        cmd="$cmd -s"
    fi
    
    $DOCKER_COMPOSE_CMD exec -T app $cmd
}

# Run API tests
run_api_tests() {
    print_status "Running API tests..."
    
    local cmd="uv run python -m pytest tests/api/ -v"
    
    if [ "$RUN_COVERAGE" = true ]; then
        cmd="$cmd --cov=apps --cov-report=html --cov-report=term-missing"
    fi
    
    if [ "$VERBOSE" = true ]; then
        cmd="$cmd -s"
    fi
    
    $DOCKER_COMPOSE_CMD exec -T app $cmd
}

# Run all Django tests
run_all_tests() {
    print_status "Running all Django tests..."
    
    local cmd="uv run python -m pytest -v"
    
    if [ "$RUN_COVERAGE" = true ]; then
        cmd="$cmd --cov=apps --cov-report=html --cov-report=term-missing"
    fi
    
    if [ "$VERBOSE" = true ]; then
        cmd="$cmd -s"
    fi
    
    $DOCKER_COMPOSE_CMD exec -T app $cmd
}

# Run linting checks
run_lint_checks() {
    print_status "Running linting checks..."
    
    echo "🔍 Running Black (code formatting check)..."
    $DOCKER_COMPOSE_CMD exec -T app uv run black --check --diff .
    
    echo ""
    echo "🔍 Running Ruff (linting)..."
    $DOCKER_COMPOSE_CMD exec -T app uv run ruff check .
    
    echo ""
    echo "🔍 Running MyPy (type checking)..."
    $DOCKER_COMPOSE_CMD exec -T app uv run mypy .
    
    echo ""
    echo "🔍 Running Django system checks..."
    $DOCKER_COMPOSE_CMD exec -T app uv run python manage.py check
}

# Run code formatting
run_code_formatting() {
    print_status "Running code formatting..."
    
    echo "🔧 Running Black (code formatter)..."
    $DOCKER_COMPOSE_CMD exec -T app uv run black .
    
    echo ""
    echo "🔧 Running Ruff (auto-fix)..."
    $DOCKER_COMPOSE_CMD exec -T app uv run ruff check --fix .
    
    print_success "Code formatting completed"
}

# Run security checks
run_security_checks() {
    print_status "Running security checks..."
    
    echo "🔒 Running Bandit (security linter)..."
    $DOCKER_COMPOSE_CMD exec -T app uv run bandit -r apps/ -f json || true
    
    echo ""
    echo "🔒 Running Django security checks..."
    $DOCKER_COMPOSE_CMD exec -T app uv run python manage.py check --deploy
    
    echo ""
    echo "🔒 Running Safety (dependency vulnerability check)..."
    $DOCKER_COMPOSE_CMD exec -T app uv run safety check || true
}

# Show coverage report
show_coverage_report() {
    if [ "$RUN_COVERAGE" = true ]; then
        echo ""
        print_success "Coverage report generated!"
        print_status "HTML report available at: htmlcov/index.html"
        print_status "To view in browser, run: open htmlcov/index.html"
    fi
}

# Main execution
main() {
    echo "🧪 Django Testing Suite"
    echo "======================="
    echo ""
    
    parse_args "$@"
    check_services
    prepare_test_db
    
    case "$TEST_TYPE" in
        "unit")
            run_unit_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "api")
            run_api_tests
            ;;
        "lint")
            run_lint_checks
            ;;
        "format")
            run_code_formatting
            ;;
        "security")
            run_security_checks
            ;;
        "")
            # Run all tests and checks
            run_all_tests
            echo ""
            run_lint_checks
            echo ""
            run_security_checks
            ;;
        *)
            print_error "Unknown test type: $TEST_TYPE"
            show_help
            exit 1
            ;;
    esac
    
    show_coverage_report
    
    echo ""
    print_success "Testing completed!"
}

# Run main function
main "$@" 