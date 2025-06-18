# 🚀 AI Development Stack - Quick Start Guide

## 🎉 You're All Set!

Your complete AI development environment is now running and optimized for Apple Silicon.

## 🌐 Access Your Tools

| Service | URL | Token/Auth |
|---------|-----|------------|
| **🎯 Jupyter Lab** | http://localhost:8889 | Token: `ai-dev-token` |
| **🗄️ ChromaDB** | http://localhost:8000 | No auth required |
| **🔄 Redis** | localhost:6380 | No auth required |

## 📁 Your Workspace

```
ai-dev-stack/
├── 📊 data/          # Store your datasets here
├── 🤖 models/        # Save trained models
├── 📓 jupyter/notebooks/  # Jupyter notebooks
├── 🚀 projects/      # Full applications
└── 🛠️ scripts/       # Utility scripts
```

## 🚀 Quick Commands

```bash
# Start the stack
./start.sh

# Stop the stack
docker-compose -f docker-compose-working.yml down

# View logs
docker-compose -f docker-compose-working.yml logs -f

# Check status
docker ps | grep ai-
```

## ☁️ Build Cloud Commands

```bash
# Build with Docker Build Cloud (faster, multi-platform)
./scripts/build-cloud.sh

# Build with Docker Bake (advanced)
docker buildx bake

# Development builds (single platform, faster)
docker buildx bake dev

# Production builds (with security scanning)
docker buildx bake production
```

## 🤖 What's Installed

### Core AI Libraries
- **PyTorch** - Deep learning framework
- **Transformers** - Hugging Face transformer models
- **Sentence Transformers** - Text embeddings
- **Scikit-learn** - Traditional ML algorithms

### Data Science Tools
- **Pandas & NumPy** - Data manipulation
- **Matplotlib & Seaborn** - Data visualization
- **Plotly** - Interactive charts

### Development Tools
- **Jupyter Lab** - Interactive development
- **ChromaDB** - Vector database for embeddings
- **Redis** - Caching and session storage

## 🎯 Get Started

1. **Open Jupyter Lab**: http://localhost:8889
2. **Run the Quick Start notebook**: `00_quick_start.ipynb`
3. **Start building your AI applications!**

## 💡 Example Use Cases

### Text Analysis
```python
from transformers import pipeline
classifier = pipeline("sentiment-analysis")
result = classifier("I love this AI development setup!")
```

### Embeddings & Search
```python
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('all-MiniLM-L6-v2')
embeddings = model.encode(["AI development", "Machine learning"])
```

### Vector Database
```python
import chromadb
client = chromadb.HttpClient(host="chroma", port=8000)
collection = client.create_collection("my_docs")
```

## 🔧 Customization

- **Add libraries**: Edit `jupyter/Dockerfile.simple` and rebuild
- **Add services**: Edit `docker-compose-working.yml`
- **Persistent data**: All volumes are persistent across restarts

## 🆘 Troubleshooting

- **Port conflicts**: Check if other services are using ports 8889, 8000, 6380
- **Container won't start**: Run `docker-compose -f docker-compose-working.yml logs [service]`
- **Out of memory**: Increase Docker Desktop memory allocation

---

**🍎 Optimized for Apple Silicon | 🐳 Powered by Docker 4.42**

Happy AI development! 🎉

