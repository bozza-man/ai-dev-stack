#!/bin/bash

# AI Dev Stack Management Script for Apple Silicon
# This script helps you manage your Docker-based AI development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}    AI Dev Stack Manager${NC}"
    echo -e "${BLUE}    Apple Silicon Optimized${NC}"
    echo -e "${BLUE}======================================${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    print_status "Docker is running ✅"
}

# Start the stack
start_stack() {
    print_header
    print_status "Starting AI Development Stack..."
    
    check_docker
    
    # Build and start services
    docker-compose build --no-cache
    docker-compose up -d
    
    print_status "Waiting for services to start..."
    sleep 10
    
    # Check service health
    check_services
    
    print_status "🚀 AI Dev Stack is ready!"
    show_urls
}

# Stop the stack
stop_stack() {
    print_status "Stopping AI Development Stack..."
    docker-compose down
    print_status "✅ Stack stopped"
}

# Restart the stack
restart_stack() {
    print_status "Restarting AI Development Stack..."
    stop_stack
    start_stack
}

# Check service health
check_services() {
    print_status "Checking service health..."
    
    services=("jupyter:8888" "api-server:8000" "vector-db:8001" "mlflow:5000" "streamlit:8501")
    
    for service in "${services[@]}"; do
        name=${service%:*}
        port=${service#*:}
        
        if docker ps --format "table {{.Names}}" | grep -q "ai-${name}"; then
            print_status "✅ ${name} is running"
        else
            print_warning "⚠️  ${name} may not be ready"
        fi
    done
}

# Show service URLs
show_urls() {
    echo ""
    print_status "🌐 Service URLs:"
    echo "  🎯 Jupyter Lab:    http://localhost:8888 (Token: ai-dev-token)"
    echo "  📡 API Server:     http://localhost:8000"
    echo "  📚 API Docs:       http://localhost:8000/docs"
    echo "  🗄️  Vector DB:      http://localhost:8001"
    echo "  📊 MLflow:         http://localhost:5000"
    echo "  🎨 Streamlit:      http://localhost:8501"
    echo ""
}

# Show logs
show_logs() {
    if [ -z "$1" ]; then
        print_status "Showing logs for all services..."
        docker-compose logs -f
    else
        print_status "Showing logs for $1..."
        docker-compose logs -f "$1"
    fi
}

# Clean up everything
cleanup() {
    print_warning "This will remove all containers, volumes, and images. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Cleaning up..."
        docker-compose down -v --rmi all
        docker system prune -f
        print_status "✅ Cleanup complete"
    else
        print_status "Cleanup cancelled"
    fi
}

# Update stack
update_stack() {
    print_status "Updating AI Development Stack..."
    git pull origin main 2>/dev/null || print_warning "Not a git repository"
    docker-compose pull
    docker-compose build --no-cache
    restart_stack
}

# Show system info
show_info() {
    print_header
    echo "🖥️  System Information:"
    echo "  Architecture: $(uname -m)"
    echo "  OS: $(uname -s)"
    echo "  Docker Version: $(docker --version)"
    echo "  Docker Compose: $(docker-compose --version)"
    echo ""
    
    if docker ps > /dev/null 2>&1; then
        echo "📦 Running Containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep ai-
    fi
    
    echo ""
    show_urls
}

# Main menu
show_menu() {
    print_header
    echo "Choose an action:"
    echo "  1) 🚀 Start Stack"
    echo "  2) 🛑 Stop Stack" 
    echo "  3) 🔄 Restart Stack"
    echo "  4) 📊 Show Status"
    echo "  5) 📋 Show Logs"
    echo "  6) 🌐 Show URLs"
    echo "  7) 🧹 Cleanup"
    echo "  8) 📥 Update"
    echo "  9) ℹ️  System Info"
    echo "  0) 👋 Exit"
    echo ""
    read -p "Enter choice [0-9]: " choice
    
    case $choice in
        1) start_stack ;;
        2) stop_stack ;;
        3) restart_stack ;;
        4) check_services ;;
        5) 
            echo "Enter service name (jupyter/api-server/vector-db/mlflow/streamlit) or press Enter for all:"
            read -r service
            show_logs "$service"
            ;;
        6) show_urls ;;
        7) cleanup ;;
        8) update_stack ;;
        9) show_info ;;
        0) print_status "Goodbye! 👋"; exit 0 ;;
        *) print_error "Invalid choice. Please try again." ;;
    esac
}

# Main execution
if [ $# -eq 0 ]; then
    while true; do
        show_menu
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
else
    case "$1" in
        start) start_stack ;;
        stop) stop_stack ;;
        restart) restart_stack ;;
        status) check_services ;;
        logs) show_logs "$2" ;;
        urls) show_urls ;;
        cleanup) cleanup ;;
        update) update_stack ;;
        info) show_info ;;
        *) 
            echo "Usage: $0 {start|stop|restart|status|logs|urls|cleanup|update|info}"
            echo "Or run without arguments for interactive mode"
            exit 1
            ;;
    esac
fi

