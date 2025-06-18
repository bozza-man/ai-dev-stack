#!/bin/bash

# Build and Push AI Development Stack Images to Private Registry
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
    echo -e "${BLUE}  AI Dev Stack - Build & Push${NC}"
    echo -e "${BLUE}  Registry: ${REGISTRY}${NC}"
    echo -e "${BLUE}======================================${NC}"
}

# Check if logged into Docker Hub
check_docker_login() {
    if ! docker info 2>/dev/null | grep -q "Username:"; then
        print_warning "You are not logged into Docker Hub"
        echo "Please run: docker login"
        echo "Username: bozzza"
        echo "Then re-run this script"
        exit 1
    fi
    
    local username=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
    if [ "$username" != "bozzza" ]; then
        print_warning "You are logged in as '$username' but need to be 'bozzza'"
        echo "Please run: docker login"
        echo "Username: bozzza"
        exit 1
    fi
    
    print_status "✅ Logged in as: $username"
}

# Build and push Jupyter image
build_jupyter() {
    print_status "Building Jupyter AI Development image..."
    docker build -f jupyter/Dockerfile.simple -t $JUPYTER_IMAGE jupyter/
    
    print_status "Pushing Jupyter image to registry..."
    docker push $JUPYTER_IMAGE
    
    print_status "✅ Jupyter image pushed: $JUPYTER_IMAGE"
}

# Build and push API server image
build_api() {
    print_status "Building FastAPI server image..."
    docker build -t $API_IMAGE api/
    
    print_status "Pushing API server image to registry..."
    docker push $API_IMAGE
    
    print_status "✅ API server image pushed: $API_IMAGE"
}

# Build and push MLflow image
build_mlflow() {
    print_status "Building MLflow image..."
    docker build -t $MLFLOW_IMAGE config/mlflow/
    
    print_status "Pushing MLflow image to registry..."
    docker push $MLFLOW_IMAGE
    
    print_status "✅ MLflow image pushed: $MLFLOW_IMAGE"
}

# Build and push Streamlit image
build_streamlit() {
    print_status "Building Streamlit image..."
    docker build -t $STREAMLIT_IMAGE config/streamlit/
    
    print_status "Pushing Streamlit image to registry..."
    docker push $STREAMLIT_IMAGE
    
    print_status "✅ Streamlit image pushed: $STREAMLIT_IMAGE"
}

# Main execution
main() {
    print_header
    
    # Check Docker login
    check_docker_login
    
    # Build and push images based on arguments
    if [ $# -eq 0 ]; then
        print_status "Building and pushing all images..."
        build_jupyter
        build_api
        build_mlflow
        build_streamlit
    else
        for service in "$@"; do
            case $service in
                jupyter)
                    build_jupyter
                    ;;
                api|api-server)
                    build_api
                    ;;
                mlflow)
                    build_mlflow
                    ;;
                streamlit)
                    build_streamlit
                    ;;
                *)
                    print_error "Unknown service: $service"
                    echo "Available services: jupyter, api, mlflow, streamlit"
                    exit 1
                    ;;
            esac
        done
    fi
    
    print_status "🎉 Build and push complete!"
    echo ""
    echo "📦 Images pushed to registry:"
    echo "  🎯 Jupyter:   $JUPYTER_IMAGE"
    echo "  📡 API:       $API_IMAGE"
    echo "  📊 MLflow:    $MLFLOW_IMAGE"
    echo "  🎨 Streamlit: $STREAMLIT_IMAGE"
    echo ""
    echo "💡 Usage:"
    echo "  Build all:        ./scripts/build-and-push.sh"
    echo "  Build specific:   ./scripts/build-and-push.sh jupyter api"
}

# Run main function with all arguments
main "$@"

