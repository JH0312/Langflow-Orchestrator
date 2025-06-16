#!/bin/bash

# LangFlow Workflow Orchestration Setup Script
# This script automates the initial setup process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main setup function
main() {
    print_header "LangFlow Workflow Orchestration Setup"
    
    # Check prerequisites
    check_prerequisites
    
    # Install dependencies
    install_dependencies
    
    # Setup environment
    setup_environment
    
    # Setup database
    setup_database
    
    # Start services
    start_services
    
    # Final instructions
    print_final_instructions
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version)
        print_success "Node.js found: $NODE_VERSION"
        
        # Check if version is 20 or higher
        NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
        if [ "$NODE_MAJOR_VERSION" -lt 20 ]; then
            print_error "Node.js version 20 or higher is required. Current version: $NODE_VERSION"
            print_info "Please install Node.js 20+ from https://nodejs.org/"
            exit 1
        fi
    else
        print_error "Node.js not found"
        print_info "Please install Node.js 20+ from https://nodejs.org/"
        exit 1
    fi
    
    # Check npm
    if command_exists npm; then
        NPM_VERSION=$(npm --version)
        print_success "npm found: $NPM_VERSION"
    else
        print_error "npm not found"
        exit 1
    fi
    
    # Check Docker
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version)
        print_success "Docker found: $DOCKER_VERSION"
    else
        print_error "Docker not found"
        print_info "Please install Docker from https://docker.com/"
        exit 1
    fi
    
    # Check Docker Compose
    if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
        if command_exists docker-compose; then
            COMPOSE_VERSION=$(docker-compose --version)
        else
            COMPOSE_VERSION=$(docker compose version)
        fi
        print_success "Docker Compose found: $COMPOSE_VERSION"
    else
        print_error "Docker Compose not found"
        print_info "Please install Docker Compose"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running"
        print_info "Please start Docker and try again"
        exit 1
    fi
}

install_dependencies() {
    print_header "Installing Dependencies"
    
    if [ -f "package.json" ]; then
        print_info "Installing npm packages..."
        npm install
        print_success "Dependencies installed"
    else
        print_error "package.json not found. Are you in the correct directory?"
        exit 1
    fi
}

setup_environment() {
    print_header "Setting up Environment"
    
    if [ ! -f ".env" ]; then
        print_info "Creating .env file..."
        
        # Generate secure secrets
        SESSION_SECRET=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | base64)
        JWT_SECRET=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | base64)
        
        cat > .env << EOF
# Database Configuration
DATABASE_URL="postgresql://postgres:password@localhost:5432/langflow_orchestration"

# Server Configuration
NODE_ENV=development
PORT=5000

# Docker Services
LANGFLOW_URL=http://localhost:7860
REDIS_URL=redis://localhost:6379

# Security
SESSION_SECRET=$SESSION_SECRET
JWT_SECRET=$JWT_SECRET

# Health Check Intervals (in seconds)
HEALTH_CHECK_INTERVAL=30
EXECUTION_TIMEOUT=300

# Logging
LOG_LEVEL=info
EOF
        
        print_success ".env file created with default configuration"
        print_warning "Please update DATABASE_URL in .env with your actual database credentials"
    else
        print_info ".env file already exists, skipping creation"
    fi
}

setup_database() {
    print_header "Setting up Database"
    
    # Check if PostgreSQL is available
    print_info "Checking database connection..."
    
    # Try to connect using the DATABASE_URL from .env
    if [ -f ".env" ]; then
        source .env
        
        # Extract database details from DATABASE_URL
        DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
        DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
        
        if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ]; then
            print_warning "Could not parse DATABASE_URL. Please ensure it's correctly formatted."
            print_info "Example: postgresql://username:password@localhost:5432/database_name"
        else
            print_info "Database host: $DB_HOST:$DB_PORT"
        fi
    fi
    
    print_info "Pushing database schema..."
    if npm run db:push; then
        print_success "Database schema updated"
    else
        print_warning "Database schema push failed. Please check your DATABASE_URL configuration."
        print_info "You can run 'npm run db:push' manually after fixing the database connection."
    fi
}

start_services() {
    print_header "Starting Services"
    
    # Start Docker services
    print_info "Starting Docker services (LangFlow + Redis)..."
    
    if [ -f "docker-compose.yml" ]; then
        if docker-compose up -d; then
            print_success "Docker services started"
            
            # Wait for services to be ready
            print_info "Waiting for services to be ready..."
            sleep 10
            
            # Check LangFlow health
            if curl -s -f http://localhost:7860/health >/dev/null 2>&1; then
                print_success "LangFlow is running and healthy"
            else
                print_warning "LangFlow may still be starting up. Check logs with: docker-compose logs langflow"
            fi
            
            # Check Redis
            if command_exists redis-cli && redis-cli ping >/dev/null 2>&1; then
                print_success "Redis is running and healthy"
            elif docker exec $(docker-compose ps -q redis) redis-cli ping >/dev/null 2>&1; then
                print_success "Redis is running and healthy"
            else
                print_warning "Redis may still be starting up. Check logs with: docker-compose logs redis"
            fi
            
        else
            print_error "Failed to start Docker services"
            exit 1
        fi
    else
        print_error "docker-compose.yml not found"
        exit 1
    fi
}

print_final_instructions() {
    print_header "Setup Complete!"
    
    echo -e "${GREEN}"
    echo "🎉 LangFlow Workflow Orchestration is ready!"
    echo -e "${NC}"
    
    echo "Next steps:"
    echo "1. Start the development server:"
    echo -e "   ${BLUE}npm run dev${NC}"
    echo ""
    echo "2. Access the application:"
    echo -e "   ${BLUE}Main Dashboard: http://localhost:5000${NC}"
    echo -e "   ${BLUE}LangFlow UI:    http://localhost:7860${NC}"
    echo ""
    echo "3. Useful commands:"
    echo -e "   ${BLUE}npm run dev${NC}        - Start development server"
    echo -e "   ${BLUE}npm run build${NC}      - Build for production"
    echo -e "   ${BLUE}npm run db:push${NC}    - Update database schema"
    echo -e "   ${BLUE}docker-compose logs${NC} - View Docker service logs"
    echo ""
    echo "4. Configuration:"
    echo -e "   ${BLUE}Edit .env file for custom configuration${NC}"
    echo -e "   ${BLUE}Update DATABASE_URL if using external database${NC}"
    echo ""
    echo "📚 For more information, see the README.md file"
    echo ""
    
    print_info "Happy orchestrating! 🚀"
}

# Cleanup function
cleanup() {
    if [ $? -ne 0 ]; then
        print_error "Setup failed. Check the error messages above."
        echo ""
        echo "Common solutions:"
        echo "- Ensure Docker is running"
        echo "- Check database connection settings in .env"
        echo "- Verify all prerequisites are installed"
        echo ""
        echo "For help, check the README.md or create an issue on GitHub"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main "$@"