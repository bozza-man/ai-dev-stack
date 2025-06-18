#!/bin/bash

# Build and Push AI Development Stack Images using Docker Build Cloud
# Registry: bozzza/bruteforcegroup
# Supports: Docker Build Cloud, multi-platform builds, advanced caching

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Registry configuration
REGISTRY="bozzza/bruteforcegroup"
JUPYTER_IMAGE="${REGISTRY}:ai-jupyter-latest"
API_IMAGE="${REGISTRY}:ai-api-server-latest"
MLFLOW_IMAGE="${REGISTRY}:ai-mlflow-latest"
STREAMLIT_IMAGE="${REGISTRY}:ai-streamlit-latest"

# Build configuration
PLATFORMS="linux/arm64,linux/amd64"  # Apple Silicon + Intel
CACHE_TYPE="registry"
CACHE_FROM="type=${CACHE_TYPE},ref=${REGISTRY}:cache"
CACHE_TO="type=${CACHE_TYPE},ref=${REGISTRY}:cache,mode=max"

# Docker Build Cloud org (set this to your org)
BUILD_CLOUD_ORG=""  # Will be detected automatically

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_cloud() {
    echo -e "${PURPLE}[CLOUD]${NC} $1"
}

print_header() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}  AI Dev Stack - Docker Build Cloud${NC}"
    echo -e "${BLUE}  Registry: ${REGISTRY}${NC}"
    echo -e "${BLUE}  Platforms: ${PLATFORMS}${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# Check Docker Build Cloud setup
check_build_cloud() {
    print_status "Checking Docker Build Cloud availability..."
    
    # Check if buildx is available
    if ! command -v docker &> /dev/null || ! docker buildx version &> /dev/null; then
        print_error "Docker buildx is not available. Please update Docker Desktop."
        exit 1
    fi
    
    # Check for cloud builders
    local cloud_builders=$(docker buildx ls | grep -E 'cloud|remote' || true)
    
    if [ -z "$cloud_builders" ]; then
        print_warning "No Docker Build Cloud builders found."
        echo "To set up Docker Build Cloud:"
        echo "1. Go to https://build.docker.com/"
        echo "2. Create an organization or use existing"
        echo "3. Run: docker buildx create --driver cloud bozzza/bruteforcegroup"
        echo ""
        echo "For now, using local builder with multi-platform support..."
        setup_local_builder
    else
        print_cloud "✅ Docker Build Cloud available!"
        echo "$cloud_builders"
        
        # Auto-detect cloud builder
        local cloud_builder=$(docker buildx ls | grep -E 'cloud|remote' | head -n1 | awk '{print $1}' | sed 's/\*//')
        if [ -n "$cloud_builder" ]; then
            print_cloud "Using cloud builder: $cloud_builder"
            BUILDER="$cloud_builder"
        else
            setup_local_builder
        fi
    fi
}

# Setup local multi-platform builder
setup_local_builder() {
    print_status "Setting up local multi-platform builder..."
    
    # Create or use existing builder
    if ! docker buildx ls | grep -q "ai-builder"; then
        docker buildx create --name ai-builder --use --bootstrap
        print_status "✅ Created multi-platform builder: ai-builder"
    else
        docker buildx use ai-builder
        print_status "✅ Using existing builder: ai-builder"
    fi
    
    BUILDER="ai-builder"
}

# Check Docker login
check_docker_login() {
    print_status "Checking Docker Hub authentication..."
    
    if ! docker info 2>/dev/null | grep -q "Username:"; then
        print_warning "You are not logged into Docker Hub"
        echo "Please run: docker login"
        echo "Username: bozzza"
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

# Build and push with cloud builder
build_with_cloud() {
    local context=$1
    local dockerfile=$2
    local image=$3
    local name=$4
    
    print_cloud "Building $name with Docker Build Cloud..."
    
    # Build arguments
    local build_args=(
        "--builder" "$BUILDER"
        "--platform" "$PLATFORMS"
        "--cache-from" "$CACHE_FROM"
        "--cache-to" "$CACHE_TO"
        "--push"
        "--tag" "$image"
    )
    
    # Add dockerfile if specified
    if [ -n "$dockerfile" ]; then
        build_args+=("--file" "$dockerfile")
    fi
    
    # Add provenance and SBOM for security
    build_args+=(
        "--provenance=true"
        "--sbom=true"
        "--metadata-file" "build-metadata-${name}.json"
    )
    
    # Execute build
    if docker buildx build "${build_args[@]}" "$context"; then
        print_cloud "✅ $name built and pushed: $image"
        
        # Show build metadata if available
        if [ -f "build-metadata-${name}.json" ]; then
            print_status "Build metadata saved: build-metadata-${name}.json"
        fi
    else
        print_error "❌ Failed to build $name"
        return 1
    fi
}

# Build Jupyter image
build_jupyter() {
    build_with_cloud \
        "jupyter/" \
        "jupyter/Dockerfile.simple" \
        "$JUPYTER_IMAGE" \
        "Jupyter AI Development"
}

# Build API server image
build_api() {
    build_with_cloud \
        "api/" \
        "" \
        "$API_IMAGE" \
        "FastAPI Server"
}

# Build MLflow image
build_mlflow() {
    build_with_cloud \
        "config/mlflow/" \
        "" \
        "$MLFLOW_IMAGE" \
        "MLflow"
}

# Build Streamlit image
build_streamlit() {
    build_with_cloud \
        "config/streamlit/" \
        "" \
        "$STREAMLIT_IMAGE" \
        "Streamlit"
}

# Show build summary
show_summary() {
    print_status "🎉 Build and push complete!"
    echo ""
    echo "📦 Multi-platform images pushed to registry:"
    echo "  🎯 Jupyter:   $JUPYTER_IMAGE"
    echo "  📡 API:       $API_IMAGE"
    echo "  📊 MLflow:    $MLFLOW_IMAGE"
    echo "  🎨 Streamlit: $STREAMLIT_IMAGE"
    echo ""
    echo "🏗️  Built for platforms: $PLATFORMS"
    echo "☁️  Cache: $CACHE_FROM"
    echo "🔧 Builder: $BUILDER"
    echo ""
    echo "📋 Build metadata files created for security scanning"
    echo ""
    echo "💡 Usage:"
    echo "  Build all:        ./scripts/build-cloud.sh"
    echo "  Build specific:   ./scripts/build-cloud.sh jupyter api"
    echo "  View metadata:    cat build-metadata-*.json"
}

# Main execution
main() {
    print_header
    
    # Setup
    check_docker_login
    check_build_cloud
    
    # Build and push images based on arguments
    if [ $# -eq 0 ]; then
        print_cloud "Building and pushing all images..."
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
    
    show_summary
}

# Handle script arguments
case "${1:-}" in
    --setup-cloud)
        echo "Setting up Docker Build Cloud..."
        echo "1. Visit: https://build.docker.com/"
        echo "2. Create/join organization: bozzza"
        echo "3. Run: docker buildx create --driver cloud bozzza/bruteforcegroup --name cloud-builder"
        echo "4. Run: docker buildx use cloud-builder"
        echo "5. Re-run this script"
        exit 0
        ;;
    --help|-h)
        echo "Docker Build Cloud AI Development Stack Builder"
        echo ""
        echo "Usage:"
        echo "  $0                    Build all services"
        echo "  $0 jupyter api       Build specific services"
        echo "  $0 --setup-cloud     Show cloud setup instructions"
        echo "  $0 --help           Show this help"
        echo ""
        echo "Services: jupyter, api, mlflow, streamlit"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac

