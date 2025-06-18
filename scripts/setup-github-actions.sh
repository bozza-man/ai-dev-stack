#!/bin/bash

# Setup GitHub Actions for AI Development Stack
# This script helps configure GitHub Actions with Docker Build Cloud

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  GitHub Actions Setup${NC}"
    echo -e "${BLUE}  Docker Build Cloud Integration${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository. Please run this script from your AI dev stack repository."
        exit 1
    fi
    
    local repo_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -z "$repo_url" ]; then
        print_warning "No 'origin' remote found. Make sure you've pushed to GitHub."
    else
        print_status "Repository: $repo_url"
    fi
}

# Check if GitHub CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) not found."
        echo "To install:"
        echo "  macOS: brew install gh"
        echo "  Linux: https://cli.github.com/manual/installation"
        echo ""
        echo "GitHub CLI is optional but helpful for setting up secrets."
        return 1
    else
        print_status "GitHub CLI found: $(gh --version | head -n1)"
        return 0
    fi
}

# Validate Docker Hub token
validate_docker_token() {
    local token="$1"
    
    if [ ${#token} -lt 20 ]; then
        print_error "Docker Hub token seems too short. Please check your token."
        return 1
    fi
    
    # Test token by attempting to authenticate
    if echo "$token" | docker login --username bozzza --password-stdin > /dev/null 2>&1; then
        print_status "✅ Docker Hub token is valid"
        docker logout > /dev/null 2>&1
        return 0
    else
        print_error "Docker Hub token authentication failed"
        return 1
    fi
}

# Setup GitHub secrets
setup_secrets() {
    print_step "Setting up GitHub repository secrets..."
    
    if ! check_gh_cli; then
        print_warning "Manual setup required for secrets:"
        echo ""
        echo "1. Go to your GitHub repository"
        echo "2. Navigate to Settings → Secrets and variables → Actions"
        echo "3. Add the following secret:"
        echo "   - Name: DOCKER_HUB_TOKEN"
        echo "   - Value: Your Docker Hub access token"
        echo ""
        echo "To create a Docker Hub access token:"
        echo "1. Log in to hub.docker.com"
        echo "2. Go to Account Settings → Security"
        echo "3. Create a new access token with 'Read, Write, Delete' permissions"
        echo ""
        return 0
    fi
    
    # Check if user is logged in to GitHub CLI
    if ! gh auth status > /dev/null 2>&1; then
        print_step "Logging in to GitHub CLI..."
        gh auth login
    fi
    
    # Get Docker Hub token from user
    echo ""
    echo "To set up GitHub Actions, we need your Docker Hub access token."
    echo "Create one at: https://hub.docker.com/settings/security"
    echo ""
    read -s -p "Enter your Docker Hub access token: " docker_token
    echo ""
    
    if validate_docker_token "$docker_token"; then
        # Set the secret
        echo "$docker_token" | gh secret set DOCKER_HUB_TOKEN
        print_success "✅ DOCKER_HUB_TOKEN secret set successfully"
    else
        print_error "Failed to validate Docker Hub token"
        return 1
    fi
}

# Setup Docker Build Cloud
setup_build_cloud() {
    print_step "Setting up Docker Build Cloud..."
    
    # Check if already set up
    if docker buildx ls | grep -q "bozzza/bruteforcegroup"; then
        print_status "✅ Docker Build Cloud builder already exists"
        return 0
    fi
    
    # Check if user is logged in to Docker
    if ! docker info | grep -q "Username: bozzza"; then
        print_warning "Please log in to Docker Hub first:"
        echo "docker login"
        echo "Username: bozzza"
        return 1
    fi
    
    print_status "Creating Docker Build Cloud builder..."
    
    if docker buildx create --driver cloud bozzza/bruteforcegroup --name cloud-builder; then
        print_status "Setting cloud builder as default..."
        docker buildx use cloud-builder
        
        print_status "Bootstrapping builder..."
        docker buildx inspect --bootstrap
        
        print_success "✅ Docker Build Cloud setup complete"
    else
        print_error "Failed to create cloud builder"
        echo ""
        echo "Make sure you have:"
        echo "1. Access to Docker Build Cloud"
        echo "2. Permission to create builders in bozzza/bruteforcegroup"
        echo "3. Visit: https://build.docker.com/"
        return 1
    fi
}

# Validate workflow files
validate_workflows() {
    print_step "Validating GitHub Actions workflow files..."
    
    local workflows_dir=".github/workflows"
    local errors=0
    
    if [ ! -d "$workflows_dir" ]; then
        print_error "Workflows directory not found: $workflows_dir"
        return 1
    fi
    
    # Check each workflow file
    for workflow in "$workflows_dir"/*.yml; do
        if [ -f "$workflow" ]; then
            echo "  Checking $(basename "$workflow")..."
            
            # Basic YAML syntax check
            if python -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
                echo "    ✅ Valid YAML syntax"
            else
                echo "    ❌ Invalid YAML syntax"
                ((errors++))
            fi
            
            # Check for required fields
            if grep -q "on:" "$workflow" && grep -q "jobs:" "$workflow"; then
                echo "    ✅ Required fields present"
            else
                echo "    ❌ Missing required fields (on/jobs)"
                ((errors++))
            fi
        fi
    done
    
    if [ $errors -eq 0 ]; then
        print_success "✅ All workflow files are valid"
        return 0
    else
        print_error "$errors workflow validation errors found"
        return 1
    fi
}

# Test build setup
test_build() {
    print_step "Testing build configuration..."
    
    # Test Docker Bake configuration
    if docker buildx bake --print > /dev/null 2>&1; then
        print_status "✅ Docker Bake configuration is valid"
    else
        print_error "❌ Docker Bake configuration has errors"
        return 1
    fi
    
    # Test Docker Compose files
    local compose_files=("docker-compose.yml" "docker-compose-working.yml" "docker-compose-cloud.yml")
    
    for compose_file in "${compose_files[@]}"; do
        if [ -f "$compose_file" ]; then
            if docker-compose -f "$compose_file" config > /dev/null 2>&1; then
                print_status "✅ $compose_file is valid"
            else
                print_error "❌ $compose_file has errors"
                return 1
            fi
        fi
    done
    
    print_success "✅ Build configuration test passed"
}

# Create initial commit and push
push_workflows() {
    print_step "Committing and pushing workflow files..."
    
    # Check if there are changes to commit
    if ! git diff --quiet HEAD .github/; then
        git add .github/
        git commit -m "feat: add GitHub Actions CI/CD with Docker Build Cloud
        
- Add comprehensive build and deploy workflow
- Add PR check workflow with linting and testing  
- Add nightly build workflow with maintenance
- Configure Docker Build Cloud integration
- Add security scanning with Trivy
- Add SBOM generation for compliance"
        
        if git push; then
            print_success "✅ Workflows pushed to GitHub"
        else
            print_warning "Failed to push to GitHub. Please push manually:"
            echo "git push"
        fi
    else
        print_status "No changes to commit"
    fi
}

# Show next steps
show_next_steps() {
    echo ""
    print_success "🎉 GitHub Actions setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo ""
    echo "1. 🔍 Check your GitHub repository:"
    echo "   - Go to the Actions tab"
    echo "   - Verify workflows are visible"
    echo ""
    echo "2. 🧪 Test the setup:"
    echo "   - Create a test branch: git checkout -b test-ci"
    echo "   - Make a small change: echo '# Test' >> README.md"
    echo "   - Push and create a PR: git add . && git commit -m 'test: CI' && git push"
    echo ""
    echo "3. 📊 Monitor builds:"
    echo "   - Check Actions tab for running workflows"
    echo "   - Review build logs and results"
    echo ""
    echo "4. 🔒 Review security:"
    echo "   - Check Security tab for scan results"
    echo "   - Review SBOM artifacts"
    echo ""
    echo "5. 📖 Read documentation:"
    echo "   - GITHUB_ACTIONS.md - Complete workflow guide"
    echo "   - DOCKER_BUILD_CLOUD.md - Build Cloud details"
    echo ""
    echo "🌩️ Your AI development stack now has enterprise-grade CI/CD!"
}

# Main execution
main() {
    print_header
    
    # Checks
    check_git_repo
    
    # Setup steps
    if setup_secrets; then
        print_success "Secrets setup complete"
    else
        print_warning "Secrets setup needs manual completion"
    fi
    
    if setup_build_cloud; then
        print_success "Build Cloud setup complete"
    else
        print_warning "Build Cloud setup needs manual completion"
    fi
    
    # Validation
    validate_workflows
    test_build
    
    # Deployment
    push_workflows
    
    # Wrap up
    show_next_steps
}

# Handle command line arguments
case "${1:-}" in
    --secrets-only)
        print_header
        setup_secrets
        ;;
    --build-cloud-only)
        print_header
        setup_build_cloud
        ;;
    --validate-only)
        print_header
        validate_workflows
        test_build
        ;;
    --help|-h)
        echo "GitHub Actions Setup Script"
        echo ""
        echo "Usage:"
        echo "  $0                    Complete setup"
        echo "  $0 --secrets-only     Setup secrets only"
        echo "  $0 --build-cloud-only Setup Build Cloud only"
        echo "  $0 --validate-only    Validate configuration only"
        echo "  $0 --help            Show this help"
        ;;
    *)
        main
        ;;
esac

