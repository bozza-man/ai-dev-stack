# 🌩️ Docker Build Cloud Configuration Guide

This guide covers setting up Docker Build Cloud for your AI Development Stack with GitHub Actions integration.

## 📋 Overview

Docker Build Cloud provides:
- ☁️ **Cloud-native builds** - Faster, more reliable builds using Docker's infrastructure
- 🚀 **Multi-platform support** - Native ARM64 + AMD64 builds
- 📦 **Advanced caching** - Intelligent layer caching across builds
- 🔒 **Enhanced security** - SBOM generation, provenance tracking
- 📊 **Build insights** - Detailed metrics and analytics

## 🎯 Current Setup Status

✅ **Multi-platform builder configured** (`ai-dev-multi`)  
✅ **GitHub Actions integration ready**  
✅ **Fallback solution active**  
⚠️ **Build Cloud pending** (requires Docker Hub setup)

## 🛠️ Setup Instructions

### Option 1: Enable Docker Build Cloud (Recommended)

1. **Visit Docker Hub Build Settings**
   ```
   https://hub.docker.com/settings/builds
   ```

2. **Enable Build Cloud for your account**
   - Sign up for Docker Build Cloud (if not already enabled)
   - Verify your account has Build Cloud access
   - Note: May require a Docker subscription

3. **Create Build Cloud Organization**
   ```bash
   # Option A: Use existing organization
   docker buildx create --driver cloud bozzza/bruteforcegroup --name ai-dev-cloud
   
   # Option B: Create new organization
   docker buildx create --driver cloud bozzza/ai-dev-stack --name ai-dev-cloud
   
   # Option C: Use personal namespace
   docker buildx create --driver cloud bozzza --name ai-dev-cloud
   ```

4. **Re-run setup script**
   ```bash
   ./scripts/setup-build-cloud.sh
   ```

5. **Update GitHub Actions workflows**
   - The script will automatically update workflows to use Build Cloud
   - Commit and push the changes

### Option 2: Continue with Multi-platform Builder (Current)

Your current setup uses `ai-dev-multi` builder with `docker-container` driver:

```bash
# Check current builder
docker buildx ls

# Test multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 .
```

**Benefits of current setup:**
- ✅ Multi-platform builds (ARM64 + AMD64)
- ✅ Advanced caching (better than default Docker)
- ✅ GitHub Actions ready
- ✅ No external dependencies

## 🔧 Configuration Details

### Environment Variables

```yaml
env:
  REGISTRY: bozzza/bruteforcegroup
  DOCKER_BUILDX_BUILDER: ai-dev-multi  # or cloud builder name
```

### GitHub Actions Integration

The workflows are configured to:

1. **Detect builder type automatically**
2. **Use appropriate caching strategies**
3. **Support multi-platform builds**
4. **Generate SBOMs and security scans**

### Workflow Configuration

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
  with:
    driver: docker-container  # or 'cloud' for Build Cloud
    install: true
```

## 🧪 Testing Your Setup

### Local Testing

```bash
# Test single platform
docker buildx build --platform linux/amd64 -t test:latest .

# Test multi-platform
docker buildx build --platform linux/amd64,linux/arm64 -t test:latest .

# Test with push to registry
docker buildx build --platform linux/amd64,linux/arm64 -t bozzza/bruteforcegroup:test --push .
```

### GitHub Actions Testing

1. **Push a small change** to trigger workflows:
   ```bash
   # Make a small change
   echo "# Test" >> README.md
   git add README.md
   git commit -m "test: Trigger build workflow"
   git push
   ```

2. **Monitor workflow execution**:
   ```bash
   gh run list --limit 5
   gh run watch <run-id>
   ```

## 📊 Performance Comparison

| Feature | Default Docker | Docker-Container | Build Cloud |
|---------|----------------|------------------|-------------|
| Multi-platform | ❌ | ✅ | ✅ |
| Advanced Caching | ❌ | ✅ | ✅✅ |
| Build Speed | Baseline | 1.5-2x faster | 2-5x faster |
| Remote Execution | ❌ | ❌ | ✅ |
| Build Analytics | ❌ | ❌ | ✅ |
| SBOM Generation | Manual | Manual | Automatic |

## 🚀 Advanced Features

### Build Cloud Benefits

When enabled, you'll get:

```yaml
# Advanced caching
cache-from: type=registry,ref=myregistry/myapp:cache
cache-to: type=registry,ref=myregistry/myapp:cache,mode=max

# Provenance and SBOM
provenance: true
sbom: true

# Build insights
annotations: |
  org.opencontainers.image.title=AI Development Stack
  org.opencontainers.image.description=Complete AI development environment
```

### Multi-platform Support

```yaml
platforms: |
  linux/amd64
  linux/arm64
  linux/arm/v7
```

### Secrets and Build Context

```yaml
secrets: |
  "github_token=${{ secrets.GITHUB_TOKEN }}"
  "docker_token=${{ secrets.DOCKER_HUB_TOKEN }}"
```

## 🔍 Troubleshooting

### Build Cloud Issues

**Error: `403 Forbidden`**
```
ERROR: unknown builder: failed to get builders: response status code: 403 Forbidden
```
**Solution:** Enable Build Cloud in Docker Hub settings

**Error: `no builders found`**
```
ERROR: unknown builder: no builders found for group: bozzza/bruteforcegroup
```
**Solution:** Create the build group in Docker Hub or use personal namespace

### Builder Issues

**Check active builder:**
```bash
docker buildx ls
```

**Reset builder:**
```bash
docker buildx rm ai-dev-multi
./scripts/setup-build-cloud.sh
```

**Test builder:**
```bash
docker buildx build --platform linux/amd64 -t test:latest -f - . <<EOF
FROM alpine:latest
RUN echo "Test successful"
EOF
```

### GitHub Actions Issues

**Check workflow status:**
```bash
gh run list --workflow="Build and Deploy"
```

**View failed run:**
```bash
gh run view <run-id> --log-failed
```

**Common fixes:**
- Verify `DOCKER_HUB_TOKEN` secret is set
- Check builder configuration in workflow files
- Ensure Docker Hub authentication is working

## 📝 Configuration Files

### Build Cloud Script
- `scripts/setup-build-cloud.sh` - Automated setup script

### Workflow Files
- `.github/workflows/build-and-deploy.yml` - Main build workflow
- `.github/workflows/pr-check.yml` - PR validation workflow
- `.github/workflows/nightly-build.yml` - Nightly maintenance workflow

### Docker Configuration
- `docker-bake.hcl` - Build configuration
- `docker-compose*.yml` - Service orchestration

## 🔄 Migration Path

### From Current Setup to Build Cloud

1. **Enable Build Cloud** in Docker Hub
2. **Run setup script**: `./scripts/setup-build-cloud.sh`
3. **Test locally**: `docker buildx build --platform linux/amd64,linux/arm64 .`
4. **Commit changes**: `git add . && git commit -m "Enable Build Cloud"`
5. **Test in CI**: `git push && gh run watch`

### Rollback Plan

If issues occur:
```bash
# Revert to docker-container builder
docker buildx create --name ai-dev-multi --driver docker-container --use

# Update workflows
sed -i 's/driver: cloud/driver: docker-container/' .github/workflows/*.yml
```

## 🎯 Next Steps

1. **✅ Current**: Multi-platform builds with docker-container
2. **🔄 Optional**: Enable Docker Build Cloud for enhanced performance
3. **🚀 Future**: Advanced build optimization and caching strategies

## 📚 Resources

- [Docker Build Cloud Documentation](https://docs.docker.com/build/cloud/)
- [Docker Buildx Documentation](https://docs.docker.com/engine/reference/commandline/buildx/)
- [GitHub Actions Docker Guide](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [Multi-platform Builds](https://docs.docker.com/build/building/multi-platform/)

---

**📧 Need Help?** 
- Check the [troubleshooting section](#-troubleshooting)
- Review workflow logs in GitHub Actions
- Test builder locally with the provided commands

