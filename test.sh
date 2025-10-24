#!/bin/bash

# Authentication Microservices Test Script
# This script tests the deployed application endpoints

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

# Default URLs
FRONTEND_URL="http://localhost:3000"
BACKEND_URL="http://localhost:3001"
AUTH_URL="http://localhost:3002"

# Function to check if URL is accessible
check_url() {
    local url=$1
    local name=$2
    
    if curl -f -s "$url" >/dev/null 2>&1; then
        print_success "$name is accessible at $url"
        return 0
    else
        print_error "$name is not accessible at $url"
        return 1
    fi
}

# Function to test health endpoints
test_health_endpoints() {
    print_status "Testing health endpoints..."
    
    # Test backend health
    if curl -f -s "$BACKEND_URL/health" >/dev/null 2>&1; then
        print_success "Backend health check passed"
    else
        print_error "Backend health check failed"
    fi
    
    # Test auth service health
    if curl -f -s "$AUTH_URL/health" >/dev/null 2>&1; then
        print_success "Auth service health check passed"
    else
        print_error "Auth service health check failed"
    fi
}

# Function to test authentication endpoints
test_auth_endpoints() {
    print_status "Testing authentication endpoints..."
    
    # Test signup endpoint
    local signup_response=$(curl -s -X POST "$AUTH_URL/auth/signup" \
        -H "Content-Type: application/json" \
        -d '{"name":"Test User","email":"testuser@example.com","password":"password123"}' \
        2>/dev/null || echo "ERROR")
    
    if [[ "$signup_response" == *"User created successfully"* ]] || [[ "$signup_response" == *"already exists"* ]]; then
        print_success "Signup endpoint is working"
    else
        print_error "Signup endpoint failed: $signup_response"
    fi
    
    # Test login endpoint
    local login_response=$(curl -s -X POST "$AUTH_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"test@example.com","password":"test123"}' \
        2>/dev/null || echo "ERROR")
    
    if [[ "$login_response" == *"Login successful"* ]]; then
        print_success "Login endpoint is working"
        
        # Extract token for further testing
        local token=$(echo "$login_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$token" ]; then
            print_success "JWT token received"
            
            # Test token verification
            local verify_response=$(curl -s -X GET "$AUTH_URL/auth/verify" \
                -H "Authorization: Bearer $token" \
                2>/dev/null || echo "ERROR")
            
            if [[ "$verify_response" == *"Token is valid"* ]]; then
                print_success "Token verification is working"
            else
                print_error "Token verification failed: $verify_response"
            fi
        fi
    else
        print_error "Login endpoint failed: $login_response"
    fi
}

# Function to test backend endpoints
test_backend_endpoints() {
    print_status "Testing backend endpoints..."
    
    # Test health endpoint
    local health_response=$(curl -s "$BACKEND_URL/health" 2>/dev/null || echo "ERROR")
    
    if [[ "$health_response" == *"OK"* ]]; then
        print_success "Backend health endpoint is working"
    else
        print_error "Backend health endpoint failed: $health_response"
    fi
}

# Function to test frontend
test_frontend() {
    print_status "Testing frontend..."
    
    local frontend_response=$(curl -s "$FRONTEND_URL" 2>/dev/null || echo "ERROR")
    
    if [[ "$frontend_response" == *"<html"* ]] || [[ "$frontend_response" == *"<!DOCTYPE"* ]]; then
        print_success "Frontend is serving HTML content"
    else
        print_error "Frontend is not serving HTML content"
    fi
}

# Function to run comprehensive tests
run_comprehensive_tests() {
    print_status "Running comprehensive tests..."
    
    local passed=0
    local total=0
    
    # Test frontend
    total=$((total + 1))
    if check_url "$FRONTEND_URL" "Frontend"; then
        passed=$((passed + 1))
    fi
    
    # Test backend
    total=$((total + 1))
    if check_url "$BACKEND_URL/health" "Backend"; then
        passed=$((passed + 1))
    fi
    
    # Test auth service
    total=$((total + 1))
    if check_url "$AUTH_URL/health" "Auth Service"; then
        passed=$((passed + 1))
    fi
    
    # Test authentication flow
    total=$((total + 1))
    if test_auth_endpoints; then
        passed=$((passed + 1))
    fi
    
    # Test backend endpoints
    total=$((total + 1))
    if test_backend_endpoints; then
        passed=$((passed + 1))
    fi
    
    # Test frontend content
    total=$((total + 1))
    if test_frontend; then
        passed=$((passed + 1))
    fi
    
    echo ""
    print_status "Test Results: $passed/$total tests passed"
    
    if [ $passed -eq $total ]; then
        print_success "All tests passed! Application is working correctly."
        return 0
    else
        print_warning "Some tests failed. Please check the logs and configuration."
        return 1
    fi
}

# Function to test with custom URLs
test_custom_urls() {
    local frontend=$1
    local backend=$2
    local auth=$3
    
    if [ -n "$frontend" ]; then
        FRONTEND_URL="$frontend"
    fi
    
    if [ -n "$backend" ]; then
        BACKEND_URL="$backend"
    fi
    
    if [ -n "$auth" ]; then
        AUTH_URL="$auth"
    fi
    
    print_status "Testing with custom URLs:"
    print_status "Frontend: $FRONTEND_URL"
    print_status "Backend: $BACKEND_URL"
    print_status "Auth Service: $AUTH_URL"
    echo ""
    
    run_comprehensive_tests
}

# Main script logic
case "$1" in
    "health")
        test_health_endpoints
        ;;
    "auth")
        test_auth_endpoints
        ;;
    "backend")
        test_backend_endpoints
        ;;
    "frontend")
        test_frontend
        ;;
    "all"|"")
        run_comprehensive_tests
        ;;
    "custom")
        test_custom_urls "$2" "$3" "$4"
        ;;
    *)
        echo "Authentication Microservices Test Script"
        echo ""
        echo "Usage: $0 {health|auth|backend|frontend|all|custom} [frontend_url] [backend_url] [auth_url]"
        echo ""
        echo "Commands:"
        echo "  health     Test health endpoints only"
        echo "  auth       Test authentication endpoints only"
        echo "  backend    Test backend endpoints only"
        echo "  frontend   Test frontend only"
        echo "  all        Run all tests (default)"
        echo "  custom     Test with custom URLs"
        echo ""
        echo "Examples:"
        echo "  $0                    # Run all tests with default URLs"
        echo "  $0 health             # Test health endpoints only"
        echo "  $0 auth               # Test authentication endpoints only"
        echo "  $0 custom http://localhost:3000 http://localhost:3001 http://localhost:3002"
        echo ""
        echo "Default URLs:"
        echo "  Frontend:  $FRONTEND_URL"
        echo "  Backend:   $BACKEND_URL"
        echo "  Auth:      $AUTH_URL"
        echo ""
        echo "Test Account:"
        echo "  Email:     test@example.com"
        echo "  Password:  test123"
        exit 1
        ;;
esac
