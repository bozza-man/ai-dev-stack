# 🚀 AI Development Stack for Apple Silicon

A complete, Docker-based AI development environment optimized for Apple Silicon (M1/M2/M3) processors. This stack provides everything you need to develop, experiment, and deploy AI applications with ease.

## 🌟 Features

### 🛠️ Core Services
- **🎯 Jupyter Lab**: Interactive development environment with pre-installed AI libraries
- **📡 FastAPI Server**: Model serving API with automatic documentation
- **🗄️ ChromaDB**: Vector database for embeddings and semantic search
- **📊 MLflow**: Experiment tracking and model registry
- **🎨 Streamlit**: Rapid prototyping and interactive web apps
- **🔄 Redis**: Caching and task queuing

### 🍎 Apple Silicon Optimized
- ARM64 native Docker images
- TensorFlow Metal acceleration support
- PyTorch MPS (Metal Performance Shaders) integration
- Optimized Python packages for M-series chips

### 🐳 Docker 4.42 Features
- Native IPv6 support for distributed AI workloads
- Enhanced model packaging capabilities
- Built-in Model Context Protocol (MCP) support
- Improved container networking

## 🚀 Quick Start

> **Status**: GitHub Actions workflows configured and ready for testing ✅

### Prerequisites
- macOS with Apple Silicon (M1/M2/M3)
- Docker Desktop 4.42+ installed and running
- At least 8GB RAM available for containers

### 1. Start the Stack

```bash
# Navigate to the stack directory
cd ~/ai-dev-stack

# Make the management script executable (if not already)
chmod +x scripts/manage.sh

# Start all services
./scripts/manage.sh start
```

### 2. Access Your Tools

Once started, you can access:

| Service | URL | Description |
|---------|-----|-------------|
| 🎯 **Jupyter Lab** | http://localhost:8888 | Interactive notebooks (Token: `ai-dev-token`) |
| 📡 **API Server** | http://localhost:8000 | Model serving REST API |
| 📚 **API Docs** | http://localhost:8000/docs | Swagger/OpenAPI documentation |
| 🗄️ **ChromaDB** | http://localhost:8001 | Vector database admin |
| 📊 **MLflow** | http://localhost:5000 | Experiment tracking dashboard |
| 🎨 **Streamlit** | http://localhost:8501 | Interactive prototyping interface |

### 3. Test Your Setup

Open Jupyter Lab and run the getting started notebook:
- Navigate to `notebooks/01_getting_started.ipynb`
- Run all cells to verify everything is working

## 🛠️ Management

Use the included management script for easy control:

```bash
# Interactive mode
./scripts/manage.sh

# Direct commands
./scripts/manage.sh start      # Start all services
./scripts/manage.sh stop       # Stop all services
./scripts/manage.sh restart    # Restart all services
./scripts/manage.sh status     # Check service health
./scripts/manage.sh logs       # View logs
./scripts/manage.sh urls       # Show service URLs
./scripts/manage.sh cleanup    # Remove everything
./scripts/manage.sh info       # Show system information
```

## 📁 Directory Structure

```
ai-dev-stack/
├── 📄 docker-compose.yml          # Main orchestration file
├── 📄 README.md                   # This file
├── 📁 api/                        # FastAPI model serving
│   ├── 🐳 Dockerfile
│   ├── 📄 requirements.txt
│   └── 🐍 main.py
├── 📁 jupyter/                    # Jupyter Lab environment
│   ├── 🐳 Dockerfile
│   ├── 🐍 startup.py
│   └── 📁 notebooks/
│       └── 📓 01_getting_started.ipynb
├── 📁 config/                     # Configuration files
│   ├── 📁 mlflow/
│   └── 📁 streamlit/
├── 📁 scripts/                    # Management utilities
│   └── 🔧 manage.sh
├── 📁 data/                       # Shared data directory
├── 📁 models/                     # Model storage
└── 📁 projects/                   # Your projects
```

## 🤖 Pre-installed AI Libraries

### Core ML Frameworks
- **PyTorch** with MPS support for Apple Silicon GPU acceleration
- **TensorFlow** with Metal optimization
- **Transformers** for pre-trained models
- **Sentence Transformers** for embeddings

### Data Science & Visualization
- **NumPy, Pandas, SciPy** for data manipulation
- **Matplotlib, Seaborn, Plotly** for visualization
- **Scikit-learn** for traditional ML

### NLP & Computer Vision
- **spaCy, NLTK** for natural language processing
- **OpenCV, Pillow** for computer vision
- **FAISS** for similarity search

### Development Tools
- **FastAPI, Uvicorn** for API development
- **Streamlit** for interactive apps
- **MLflow** for experiment tracking
- **ChromaDB** for vector operations

## 🔧 Customization

### Adding New Services

1. Add your service to `docker-compose.yml`:
```yaml
your-service:
  build: ./your-service
  ports:
    - "your-port:your-port"
  networks:
    - ai-network
```

2. Update the management script to include your service

### Installing Additional Libraries

Option 1 - Rebuild containers:
```bash
# Add to requirements.txt or Dockerfile
./scripts/manage.sh restart
```

Option 2 - Install at runtime:
```bash
# In Jupyter notebook
!pip install your-library
```

### Persistent Data

Data in these directories persists between container restarts:
- `./data/` - Datasets and files
- `./models/` - Trained models
- `./jupyter/notebooks/` - Your notebooks
- Docker volumes for databases

## 🚨 Troubleshooting

### Container Won't Start
```bash
# Check Docker status
docker info

# View detailed logs
./scripts/manage.sh logs [service-name]

# Rebuild from scratch
./scripts/manage.sh cleanup
./scripts/manage.sh start
```

### Port Conflicts
If ports are already in use, modify `docker-compose.yml`:
```yaml
ports:
  - "8889:8888"  # Change host port
```

### Memory Issues
Increase Docker Desktop memory allocation:
1. Docker Desktop → Settings → Resources
2. Set Memory to at least 8GB
3. Apply & Restart

### Model Download Failures
```bash
# Check internet connection in container
docker exec -it ai-jupyter curl -I https://huggingface.co

# Clear model cache
rm -rf ~/.cache/huggingface/
```

## 📈 Performance Tips

### Apple Silicon Optimization
- Enable Metal acceleration in TensorFlow:
  ```python
  import tensorflow as tf
  print("GPUs:", tf.config.list_physical_devices('GPU'))
  ```

- Use MPS in PyTorch:
  ```python
  import torch
  device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
  ```

### Memory Management
- Monitor container memory usage:
  ```bash
  docker stats
  ```

- Optimize model loading:
  ```python
  # Load models with reduced precision
  model = AutoModel.from_pretrained(model_name, torch_dtype=torch.float16)
  ```

## 🔒 Security Considerations

### Production Deployment
- Change default tokens and passwords
- Use environment variables for secrets
- Enable HTTPS/TLS
- Implement proper authentication
- Regular security updates

### Development Safety
- Keep containers updated
- Don't expose unnecessary ports
- Use non-root users where possible
- Regular backup of important data

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## 📚 Resources

### Documentation
- [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/)
- [Apple Silicon Optimization Guide](https://developer.apple.com/metal/)
- [MLflow Documentation](https://mlflow.org/docs/)
- [ChromaDB Documentation](https://docs.trychroma.com/)

### Tutorials
- Check the `notebooks/` directory for examples
- Visit the Streamlit dashboard for interactive tutorials
- Explore the API documentation at `/docs`

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎉 What's Next?

Now that your AI development stack is running, you can:

1. **🔬 Experiment** with pre-trained models in Jupyter
2. **🏗️ Build** custom APIs with FastAPI
3. **📊 Track** experiments with MLflow
4. **🎨 Prototype** with Streamlit
5. **🔍 Search** with vector databases
6. **🚀 Deploy** your models

Happy AI development on Apple Silicon! 🍎🤖

---

*Built with ❤️ for the AI development community*

