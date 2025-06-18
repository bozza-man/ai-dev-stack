# 🌩️ Docker Build Cloud Integration

Your AI development stack now supports **Docker Build Cloud** for faster, more efficient builds with shared caching and multi-platform support.

## 🚀 Quick Start

### Option 1: Use Build Cloud Script
```bash
# Build all services with Build Cloud
./scripts/build-cloud.sh

# Build specific services
./scripts/build-cloud.sh jupyter api
```

### Option 2: Use Docker Bake
```bash
# Build all services
docker buildx bake

# Build production images with security scanning
docker buildx bake production

# Build development images (faster, single platform)
docker buildx bake dev
```

## ⚙️ Setup Docker Build Cloud

### 1. Sign up and Create Organization
1. Visit [build.docker.com](https://build.docker.com/)
2. Sign in with your Docker Hub account (`bozzza`)
3. Create or join the organization for your builds

### 2. Create Cloud Builder
```bash
# Create a cloud builder for your organization
docker buildx create \
  --driver cloud \
  bozzza/bruteforcegroup \
  --name cloud-builder

# Use the cloud builder
docker buildx use cloud-builder

# Bootstrap the builder
docker buildx inspect --bootstrap
```

### 3. Verify Setup
```bash
# Check available builders
docker buildx ls

# Should show something like:
# cloud-builder*  cloud    bozzza/bruteforcegroup  running  v0.x.x  linux/amd64*, linux/arm64*
```

## 🏗️ Build Options

### Standard Builds
```bash
# Build all services
./scripts/build-cloud.sh

# Build specific services
./scripts/build-cloud.sh jupyter mlflow
```

### Advanced Builds with Bake
```bash
# All services (multi-platform)
docker buildx bake

# Production builds (with security scanning)
docker buildx bake production

# Development builds (single platform, faster)
docker buildx bake dev

# Specific service
docker buildx bake jupyter

# Custom variables
REGISTRY=your-registry docker buildx bake
```

### Local Development Builds
```bash
# Fast local builds for development
docker buildx bake dev

# Load into local Docker
docker buildx bake jupyter-dev --load
```

## 📊 Benefits of Docker Build Cloud

### 🚀 **Performance**
- **Faster builds**: Cloud builders with high-performance compute
- **Shared cache**: Team members benefit from each other's builds
- **Parallel builds**: Multiple services built simultaneously

### 🌍 **Multi-Platform**
- **Native ARM64 + AMD64**: Perfect for Apple Silicon development
- **Cross-platform builds**: Single command for multiple architectures
- **Consistent results**: Same image works everywhere

### 🔒 **Security & Compliance**
- **SBOM generation**: Software Bill of Materials for security
- **Provenance**: Cryptographic proof of build authenticity
- **Vulnerability scanning**: Built-in security checks

### 👥 **Team Collaboration**
- **Shared builders**: Consistent build environment for all team members
- **Cache sharing**: Faster builds for everyone
- **Build history**: Track and debug builds across the team

## 🔧 Configuration Files

### `docker-bake.hcl`
Advanced build configuration with:
- Multi-platform builds
- Shared caching
- Security scanning
- Development vs production targets

### `docker-compose-cloud.yml`
Docker Compose file optimized for:
- Multi-platform images
- Registry caching
- Build Cloud integration

### `scripts/build-cloud.sh`
Intelligent build script that:
- Auto-detects cloud builders
- Falls back to local builders
- Provides detailed logging
- Handles authentication

## 📈 Build Strategies

### Development Workflow
```bash
# Fast local development
docker buildx bake dev

# Test specific service
docker buildx bake jupyter-dev --load
docker run -p 8889:8888 ai-jupyter:dev
```

### CI/CD Pipeline
```bash
# Production builds with full scanning
docker buildx bake production

# Tagged releases
REGISTRY=bozzza/bruteforcegroup docker buildx bake \
  --set '*.tags=bozzza/bruteforcegroup:v1.0.0'
```

### Team Builds
```bash
# Shared cache benefits
docker buildx bake  # Uses shared cache from team builds
```

## 🐛 Troubleshooting

### Cloud Builder Not Available
```bash
# Check builders
docker buildx ls

# Create new cloud builder
docker buildx create --driver cloud bozzza/bruteforcegroup --name cloud-builder

# Use cloud builder
docker buildx use cloud-builder
```

### Authentication Issues
```bash
# Login to Docker Hub
docker login

# Verify login
docker info | grep Username
```

### Build Failures
```bash
# Check builder status
docker buildx inspect

# View build logs
docker buildx bake --progress=plain

# Reset builder
docker buildx rm cloud-builder
docker buildx create --driver cloud bozzza/bruteforcegroup --name cloud-builder
```

### Cache Issues
```bash
# Clear cache
docker buildx prune

# Disable cache for debugging
docker buildx bake --no-cache
```

## 📋 Command Reference

### Build Cloud Script
```bash
./scripts/build-cloud.sh                    # Build all services
./scripts/build-cloud.sh jupyter api        # Build specific services
./scripts/build-cloud.sh --setup-cloud      # Show setup instructions
./scripts/build-cloud.sh --help            # Show help
```

### Docker Bake Commands
```bash
docker buildx bake                          # Build default group
docker buildx bake production               # Build with security scanning
docker buildx bake dev                      # Fast development builds
docker buildx bake jupyter                  # Build specific service
docker buildx bake --print                  # Show what would be built
docker buildx bake --progress=plain         # Verbose output
```

### Builder Management
```bash
docker buildx ls                            # List builders
docker buildx use <builder>                 # Switch builder
docker buildx inspect                       # Show builder details
docker buildx rm <builder>                  # Remove builder
docker buildx prune                         # Clean cache
```

## 🎯 Best Practices

1. **Use Cloud Builders**: For faster, consistent builds
2. **Leverage Caching**: Let the team benefit from shared cache
3. **Multi-Platform**: Build for both ARM64 and AMD64
4. **Security First**: Use production targets for releases
5. **Local Development**: Use dev targets for rapid iteration

---

**🌩️ Powered by Docker Build Cloud | 🍎 Optimized for Apple Silicon**

