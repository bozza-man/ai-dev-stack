# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based AI development stack optimized for Apple Silicon (M1/M2/M3) processors. The stack provides a complete development environment for AI/ML applications with pre-configured services and libraries.

## Architecture

The stack consists of multiple Docker services orchestrated via docker-compose:

- **Jupyter Lab** (`ai-jupyter`): Interactive development environment with AI/ML libraries
- **FastAPI Server** (`ai-api`): Model serving API with automatic documentation  
- **ChromaDB** (`ai-chroma`): Vector database for embeddings and semantic search
- **Redis** (`ai-redis`): Caching and task queuing
- **MLflow** (`ai-mlflow`): Experiment tracking and model registry
- **Streamlit** (`ai-streamlit`): Rapid prototyping and interactive web apps

All services communicate through a custom Docker network (`ai-network`) and use persistent volumes for data storage.

## Common Commands

### Stack Management
```bash
# Start the complete stack
./start.sh
# OR use the management script
./scripts/manage.sh start

# Stop the stack
docker-compose -f docker-compose-working.yml down

# Interactive management (recommended)
./scripts/manage.sh

# Check service status
docker ps | grep ai-

# View logs
docker-compose -f docker-compose-working.yml logs -f
docker-compose -f docker-compose-working.yml logs -f [service-name]

# Restart services
./scripts/manage.sh restart
```

### Development Workflow
```bash
# Build and start with cache rebuild
docker-compose -f docker-compose-working.yml up --build -d

# Access services (ports vary by compose file)
# Jupyter Lab: http://localhost:8888 (main) or http://localhost:8889 (working)
# Token: ai-dev-token
# ChromaDB: http://localhost:8000 (working) or http://localhost:8001 (main)
# Redis: localhost:6380 (working) or localhost:6379 (main)
# API Server: http://localhost:8000 (main compose file only)
# MLflow: http://localhost:5000 (main compose file only)
# Streamlit: http://localhost:8501 (main compose file only)

# Container debugging
docker exec -it ai-jupyter bash    # Access Jupyter container
docker exec -it ai-chroma bash     # Access ChromaDB container
docker logs ai-jupyter             # View specific service logs
```

## Configuration Files

- `docker-compose.yml`: Full stack with all services (Jupyter:8888, API:8000, ChromaDB:8001, MLflow:5000, Streamlit:8501)
- `docker-compose-working.yml`: Minimal stack (Jupyter:8889, ChromaDB:8000, Redis:6380)
- `docker-compose-quick.yml`: Quick start configuration
- `start.sh`: Simple startup script for minimal stack using docker-compose-working.yml
- `scripts/manage.sh`: Comprehensive management script with interactive menu

### Container Services Map
```
docker-compose.yml (full):       docker-compose-working.yml (minimal):
├── ai-jupyter:8888             ├── ai-jupyter:8889
├── ai-api:8000                 ├── ai-chroma:8000
├── ai-chroma:8001              └── ai-redis:6380
├── ai-redis:6379
├── ai-mlflow:5000
└── ai-streamlit:8501
```

## Service Architecture

### Jupyter Environment
- Base: `jupyter/base-notebook:latest`
- Custom workspace structure: `/home/jovyan/workspace/{data,models,notebooks,projects}`
- Pre-installed: PyTorch, Transformers, Sentence-Transformers, Pandas, NumPy, Scikit-learn
- Startup script: `jupyter/startup.py` with environment setup

### API Server
- FastAPI application in `api/main.py`
- Pre-loaded models: SentenceTransformer (embeddings), DistilGPT2 (text generation)
- Endpoints: `/generate`, `/embeddings`, `/similarity`, `/models`
- Connected to ChromaDB and Redis services

### Data Persistence
- `./data/`: Shared datasets directory
- `./models/`: Model storage directory  
- `./jupyter/notebooks/`: Jupyter notebooks
- `./projects/`: Full applications
- Docker volumes: `chroma_data`, `redis_data`, `mlflow_data`

## Development Patterns

### Working with Models
- Models are loaded in `api/main.py` startup event
- Use SentenceTransformer for embeddings via `/embeddings` endpoint
- Text generation available via `/generate` endpoint
- Custom model loading supported via upload endpoint

### Vector Database Integration
- ChromaDB client accessible at `chroma:8000` from containers
- Redis client at `redis:6379` from containers
- Python clients pre-configured in API service

### Apple Silicon Optimization
- PyTorch with MPS backend support
- ARM64 native Docker images
- TensorFlow Metal acceleration support
- Optimized Python packages for M-series chips

## File Structure Conventions

```
ai-dev-stack/
├── api/                    # FastAPI model serving
├── config/                 # Service configurations
│   ├── mlflow/            # MLflow setup
│   └── streamlit/         # Streamlit apps
├── data/                  # Persistent datasets
├── jupyter/               # Jupyter environment
│   ├── notebooks/         # Development notebooks
│   └── startup.py         # Environment setup
├── models/                # Model storage
├── projects/             # Full applications
└── scripts/              # Management utilities
```

## Testing and Validation

### Quick Start Verification
Use the provided notebooks to verify setup:
- `jupyter/notebooks/00_quick_start.ipynb`
- `jupyter/notebooks/01_getting_started.ipynb`

### API Testing (when using docker-compose.yml)
- Swagger UI: `http://localhost:8000/docs`
- Health check: `http://localhost:8000/health`
- Model endpoints: `/generate`, `/embeddings`, `/similarity`, `/models`

### Management Script Commands
```bash
# Extended management options
./scripts/manage.sh status     # Check all service health
./scripts/manage.sh logs       # View logs with service selection
./scripts/manage.sh urls       # Display all service URLs
./scripts/manage.sh cleanup    # Remove containers and volumes
./scripts/manage.sh info       # Show system and Docker info
```

### Troubleshooting Commands
```bash
# Check service health
docker ps | grep ai-
docker stats --no-stream | grep ai-

# Debug container issues
docker exec -it ai-jupyter pip list    # Check installed packages
docker exec -it ai-jupyter python -c "import torch; print(torch.__version__)"
docker exec -it ai-chroma curl localhost:8000/api/v1/heartbeat

# Resource monitoring
docker system df          # Check disk usage
docker system prune -f    # Clean up unused resources
```