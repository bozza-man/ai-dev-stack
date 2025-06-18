FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Streamlit and AI libraries
RUN pip install --no-cache-dir \
    streamlit==1.28.1 \
    pandas==2.0.3 \
    numpy==1.24.3 \
    matplotlib==3.7.2 \
    seaborn==0.12.2 \
    plotly==5.17.0 \
    requests==2.31.0 \
    httpx==0.25.0 \
    pillow==10.1.0

# Create app directory structure
RUN mkdir -p /app/pages /app/data /app/models

# Copy default app
COPY app.py /app/
COPY pages/ /app/pages/

# Expose port
EXPOSE 8501

# Configure Streamlit
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0

# Start Streamlit
CMD ["streamlit", "run", "app.py", "--server.address", "0.0.0.0", "--server.port", "8501"]

