FROM jupyter/scipy-notebook:latest

USER root

# Install system dependencies for Apple Silicon
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    vim \
    htop \
    tree \
    jq \
    && rm -rf /var/lib/apt/lists/*

USER jovyan

# Install Python AI/ML packages optimized for ARM64
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    torch \
    transformers \
    datasets \
    sentence-transformers \
    chromadb \
    faiss-cpu \
    pandas \
    numpy \
    scipy \
    scikit-learn \
    matplotlib \
    seaborn \
    plotly \
    spacy \
    nltk \
    opencv-python \
    pillow \
    fastapi \
    uvicorn \
    requests \
    httpx \
    mlflow \
    jupyterlab-git \
    jupyterlab-widgets \
    ipywidgets \
    black \
    isort \
    flake8 \
    pytest \
    pydantic \
    python-dotenv \
    tqdm \
    rich

# Install additional Jupyter extensions
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager

# Download spacy model
RUN python -m spacy download en_core_web_sm

# Create workspace directories
RUN mkdir -p /home/jovyan/workspace/{data,models,notebooks,projects}

# Set working directory
WORKDIR /home/jovyan/workspace

# Copy startup script
COPY --chown=jovyan:users startup.py /home/jovyan/

# Expose port
EXPOSE 8888

# Start Jupyter Lab
CMD ["start-notebook.sh", "--NotebookApp.token='ai-dev-token'", "--NotebookApp.password=''"]

