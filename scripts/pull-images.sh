#!/bin/bash

# Pull AI Development Stack Images from Private Registry
# Registry: bozzza/bruteforcegroup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Registry configuration
REGISTRY="bozzza/bruteforcegroup"
JUPYTER_IMAGE="${REGISTRY}:ai-jupyter-latest"
API_IMAGE="${REGISTRY}:ai-api-server-latest"
MLFLOW_IMAGE="${REGISTRY}:ai-mlflow-latest"
STREAMLIT_IMAGE="${REGISTRY}:ai-streamlit-latest"

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
    echo -e "${BLUE}  AI Dev Stack - Pull Images${NC}"
    echo -e "${BLUE}  Registry: ${REGISTRY}${NC}"
    echo -e "${BLUE}======================================${NC}"
}

# Check if logged into Docker Hub
check_docker_login() {
    if ! docker system info | grep -q "Username:"; then
        print_warning "You are not logged into Docker Hub"
        echo "Please run: docker login"
        echo "Username: bozzza"
        echo "Then re-run this script"
        exit 1
    fi
    
    local username=$(docker system info | grep "Username:" | awk '{print $2}')
    if [ "$username" != "bozzza" ]; then
        print_warning "You are logged in as '$username' but need to be 'bozzza'"
        echo "Please run: docker login"
        echo "Username: bozzza"
        exit 1
    fi
    
    print_status "✅ Logged in as: $username"
}

# Pull specific image
pull_image() {
    local image=$1
    local name=$2
    
    print_status "Pulling $name image..."
    if docker pull $image; then
        print_status "✅ $name image pulled: $image"
    else
        print_error "❌ Failed to pull $name image: $image"
        return 1
    fi
}

# Main execution
main() {
    print_header
    
    # Check Docker login
    check_docker_login
    
    # Pull images based on arguments
    if [ $# -eq 0 ]; then
        print_status "Pulling all images..."
        pull_image $JUPYTER_IMAGE "Jupyter"
        pull_image $API_IMAGE "API Server"
        pull_image $MLFLOW_IMAGE "MLflow"
        pull_image $STREAMLIT_IMAGE "Streamlit"
    else
        for service in "$@"; do
            case $service in
                jupyter)
                    pull_image $JUPYTER_IMAGE "Jupyter"
                    ;;
                api|api-server)
                    pull_image $API_IMAGE "API Server"
                    ;;
                mlflow)
                    pull_image $MLFLOW_IMAGE "MLflow"
                    ;;
                streamlit)
                    pull_image $STREAMLIT_IMAGE "Streamlit"
                    ;;
                *)
                    print_error "Unknown service: $service"
                    echo "Available services: jupyter, api, mlflow, streamlit"
                    exit 1
                    ;;
            esac
        done
    fi
    
    print_status "🎉 Pull complete!"
    echo ""
    echo "📦 Images available locally:"
    echo "  🎯 Jupyter:   $JUPYTER_IMAGE"
    echo "  📡 API:       $API_IMAGE"
    echo "  📊 MLflow:    $MLFLOW_IMAGE"
    echo "  🎨 Streamlit: $STREAMLIT_IMAGE"
    echo ""
    echo "💡 Usage:"
    echo "  Pull all:        ./scripts/pull-images.sh"
    echo "  Pull specific:   ./scripts/pull-images.sh jupyter api"
}

# Run main function with all arguments
main "$@"

