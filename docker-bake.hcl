# Docker Bake file for AI Development Stack
# Optimized for Docker Build Cloud with multi-platform builds

variable "REGISTRY" {
  default = "bozzza/bruteforcegroup"
}

variable "PLATFORMS" {
  default = ["linux/arm64", "linux/amd64"]
}

variable "CACHE_FROM" {
  default = ["type=registry,ref=bozzza/bruteforcegroup:cache"]
}

variable "CACHE_TO" {
  default = ["type=registry,ref=bozzza/bruteforcegroup:cache,mode=max"]
}

# Default group - builds all services
group "default" {
  targets = ["jupyter", "api-server", "mlflow", "streamlit"]
}

# Production group - includes security scanning
group "production" {
  targets = ["jupyter-prod", "api-server-prod", "mlflow-prod", "streamlit-prod"]
}

# Base target with common settings
target "_common" {
  platforms = ["linux/arm64", "linux/amd64"]
  cache-from = ["type=registry,ref=bozzza/bruteforcegroup:cache"]
  cache-to = ["type=registry,ref=bozzza/bruteforcegroup:cache,mode=max"]
  
  # Security and metadata
  provenance = true
  sbom = true
  
  # Build arguments for Apple Silicon optimization
  args = {
    BUILDPLATFORM = "linux/arm64"
    TARGETPLATFORM = "linux/arm64"
  }
}

# Jupyter Lab target
target "jupyter" {
  inherits = ["_common"]
  context = "./jupyter"
  dockerfile = "Dockerfile.simple"
  tags = ["${REGISTRY}:ai-jupyter-latest", "${REGISTRY}:ai-jupyter-${formatdate("YYYY-MM-DD", timestamp())}"]
  
  output = ["type=registry"]
  
  # Jupyter-specific optimizations
  args = {
    JUPYTER_VERSION = "latest"
    PYTHON_VERSION = "3.11"
  }
}

# Production Jupyter with vulnerability scanning
target "jupyter-prod" {
  inherits = ["jupyter"]
  tags = ["${REGISTRY}:ai-jupyter-prod"]
  
  # Add vulnerability scanning
  attestations = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
}

# FastAPI Server target
target "api-server" {
  inherits = ["_common"]
  context = "./api"
  tags = ["${REGISTRY}:ai-api-server-latest", "${REGISTRY}:ai-api-server-${formatdate("YYYY-MM-DD", timestamp())}"]
  
  output = ["type=registry"]
  
  # API-specific optimizations
  args = {
    FASTAPI_VERSION = "latest"
    PYTHON_VERSION = "3.11"
  }
}

target "api-server-prod" {
  inherits = ["api-server"]
  tags = ["${REGISTRY}:ai-api-server-prod"]
  attestations = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
}

# MLflow target
target "mlflow" {
  inherits = ["_common"]
  context = "./config/mlflow"
  tags = ["${REGISTRY}:ai-mlflow-latest", "${REGISTRY}:ai-mlflow-${formatdate("YYYY-MM-DD", timestamp())}"]
  
  output = ["type=registry"]
  
  args = {
    MLFLOW_VERSION = "2.8.1"
    PYTHON_VERSION = "3.11"
  }
}

target "mlflow-prod" {
  inherits = ["mlflow"]
  tags = ["${REGISTRY}:ai-mlflow-prod"]
  attestations = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
}

# Streamlit target
target "streamlit" {
  inherits = ["_common"]
  context = "./config/streamlit"
  tags = ["${REGISTRY}:ai-streamlit-latest", "${REGISTRY}:ai-streamlit-${formatdate("YYYY-MM-DD", timestamp())}"]
  
  output = ["type=registry"]
  
  args = {
    STREAMLIT_VERSION = "1.28.1"
    PYTHON_VERSION = "3.11"
  }
}

target "streamlit-prod" {
  inherits = ["streamlit"]
  tags = ["${REGISTRY}:ai-streamlit-prod"]
  attestations = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
}

# Development target - single platform for faster builds
target "dev" {
  inherits = ["_common"]
  platforms = ["linux/arm64"]  # Apple Silicon only for dev
  cache-to = []  # No cache push for dev builds
  
  output = ["type=docker"]  # Load into local Docker
}

# Development group
group "dev" {
  targets = ["jupyter-dev", "api-server-dev"]
}

target "jupyter-dev" {
  inherits = ["jupyter", "dev"]
  tags = ["ai-jupyter:dev"]
}

target "api-server-dev" {
  inherits = ["api-server", "dev"]
  tags = ["ai-api-server:dev"]
}

