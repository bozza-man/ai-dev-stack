#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Docker Build Cloud Setup${NC}"
echo -e "${BLUE}  AI Development Stack${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check Docker login
echo -e "${BLUE}[STEP 1]${NC} Checking Docker Hub authentication..."
if ! docker info --format json | jq -r '.RegistryConfig.Username' | grep -q "bozzza"; then
    echo -e "${YELLOW}⚠️  Not logged into Docker Hub. Please log in:${NC}"
    docker login --username bozzza
fi

echo -e "${GREEN}✅ Docker Hub authentication verified${NC}"

# Check Buildx version
echo -e "${BLUE}[STEP 2]${NC} Checking Docker Buildx version..."
BUILDX_VERSION=$(docker buildx version | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')
echo -e "${GREEN}✅ Docker Buildx ${BUILDX_VERSION} detected${NC}"

# Try to set up Build Cloud
echo -e "${BLUE}[STEP 3]${NC} Attempting Docker Build Cloud setup..."

# Function to try different build cloud endpoints
try_build_cloud() {
    local endpoint="$1"
    local name="$2"
    
    echo -e "${YELLOW}🔄 Trying to create Build Cloud builder: ${endpoint}${NC}"
    
    if docker buildx create --driver cloud "$endpoint" --name "$name" 2>/dev/null; then
        echo -e "${GREEN}✅ Build Cloud builder '${name}' created successfully${NC}"
        docker buildx use "$name"
        return 0
    else
        echo -e "${YELLOW}⚠️  Failed to create Build Cloud builder with endpoint: ${endpoint}${NC}"
        return 1
    fi
}

# Try different Build Cloud configurations
BUILD_CLOUD_SUCCESS=false

# Try organization endpoint
if try_build_cloud "bozzza/bruteforcegroup" "ai-dev-cloud-org"; then
    BUILD_CLOUD_SUCCESS=true
# Try user endpoint
elif try_build_cloud "bozzza" "ai-dev-cloud-user"; then
    BUILD_CLOUD_SUCCESS=true
# Try creating a new builder group
elif try_build_cloud "bozzza/ai-dev-stack" "ai-dev-cloud-project"; then
    BUILD_CLOUD_SUCCESS=true
fi

if [ "$BUILD_CLOUD_SUCCESS" = true ]; then
    echo -e "${GREEN}🎉 Docker Build Cloud setup successful!${NC}"
    echo -e "${BLUE}Active builders:${NC}"
    docker buildx ls
else
    echo -e "${YELLOW}⚠️  Docker Build Cloud setup failed. Setting up fallback solution...${NC}"
    
    # Create multi-platform builder as fallback
    echo -e "${BLUE}[FALLBACK]${NC} Creating multi-platform buildx builder..."
    
    # Remove any existing builders with our name
    docker buildx rm ai-dev-multi 2>/dev/null || true
    
    # Create new multi-platform builder
    docker buildx create \
        --name ai-dev-multi \
        --driver docker-container \
        --bootstrap \
        --use
    
    echo -e "${GREEN}✅ Multi-platform builder 'ai-dev-multi' created${NC}"
    echo -e "${BLUE}Active builders:${NC}"
    docker buildx ls
fi

# Test the builder
echo -e "${BLUE}[STEP 4]${NC} Testing builder functionality..."
ACTIVE_BUILDER=$(docker buildx ls | grep '\*' | awk '{print $1}')
echo -e "${BLUE}Testing builder: ${ACTIVE_BUILDER}${NC}"

# Create a simple test Dockerfile
cat > /tmp/test.Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Build test successful" > /test.txt
CMD cat /test.txt
EOF

echo -e "${YELLOW}🧪 Running build test...${NC}"
if docker buildx build --platform linux/amd64 -f /tmp/test.Dockerfile -t test-build:latest --load . >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Builder test successful${NC}"
    docker rmi test-build:latest >/dev/null 2>&1 || true
else
    echo -e "${RED}❌ Builder test failed${NC}"
fi

# Clean up
rm -f /tmp/test.Dockerfile

# Update GitHub Actions workflows
echo -e "${BLUE}[STEP 5]${NC} Updating GitHub Actions workflows..."

# Determine the builder configuration for GitHub Actions
if [ "$BUILD_CLOUD_SUCCESS" = true ]; then
    BUILDER_CONFIG="cloud"
    ENDPOINT=$(docker buildx ls | grep '\*' | grep cloud | awk '{print $3}')
    echo -e "${GREEN}✅ Using Build Cloud configuration${NC}"
    echo -e "${BLUE}   Driver: cloud${NC}"
    echo -e "${BLUE}   Endpoint: ${ENDPOINT}${NC}"
else
    BUILDER_CONFIG="docker-container"
    echo -e "${GREEN}✅ Using multi-platform builder configuration${NC}"
    echo -e "${BLUE}   Driver: docker-container${NC}"
fi

# Create workflow update script
cat > update-workflows.sh << 'EOF'
#!/bin/bash

# This script updates the GitHub Actions workflows based on the builder configuration
BUILDER_TYPE="$1"
ENDPOINT="$2"

update_workflow() {
    local file="$1"
    local driver="$2"
    local endpoint_param="$3"
    
    if [ "$driver" = "cloud" ]; then
        # Update for Build Cloud
        sed -i.bak "s/driver: cloud/driver: cloud/" "$file"
        if [ -n "$endpoint_param" ]; then
            sed -i.bak "s/endpoint: .*/endpoint: $endpoint_param/" "$file"
        fi
    else
        # Update for docker-container
        sed -i.bak "s/driver: cloud/driver: docker-container/" "$file"
        sed -i.bak "/endpoint:/d" "$file"
    fi
    
    rm -f "$file.bak"
}

# Update all workflow files
for workflow in .github/workflows/*.yml; do
    if grep -q "setup-buildx-action" "$workflow"; then
        echo "Updating $workflow for $driver driver..."
        update_workflow "$workflow" "$driver" "$endpoint_param"
    fi
done

echo "✅ Workflows updated for $driver driver"
EOF

chmod +x update-workflows.sh

if [ "$BUILD_CLOUD_SUCCESS" = true ]; then
    ./update-workflows.sh "cloud" "$ENDPOINT"
else
    ./update-workflows.sh "docker-container" ""
fi

rm -f update-workflows.sh

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"

if [ "$BUILD_CLOUD_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ Docker Build Cloud configured and ready${NC}"
    echo -e "${BLUE}   Your builds will use Docker's cloud infrastructure${NC}"
    echo -e "${BLUE}   Benefits: Faster builds, better caching, multi-platform support${NC}"
else
    echo -e "${GREEN}✅ Multi-platform builder configured and ready${NC}"
    echo -e "${BLUE}   Your builds will use local Docker container builder${NC}"
    echo -e "${BLUE}   Benefits: Multi-platform support, better caching than default${NC}"
    echo ""
    echo -e "${YELLOW}💡 To enable Docker Build Cloud later:${NC}"
    echo -e "${YELLOW}   1. Visit: https://hub.docker.com/settings/builds${NC}"
    echo -e "${YELLOW}   2. Enable Build Cloud for your account${NC}"
    echo -e "${YELLOW}   3. Re-run this script${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "${BLUE}   1. Test your build: docker buildx build --platform linux/amd64,linux/arm64 .${NC}"
echo -e "${BLUE}   2. Push changes: git add . && git commit -m 'Configure Docker buildx'${NC}"
echo -e "${BLUE}   3. Test GitHub Actions: git push${NC}"

echo -e "${BLUE}========================================${NC}"

