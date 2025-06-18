FROM python:3.11-slim

WORKDIR /mlflow

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install MLflow and dependencies
RUN pip install --no-cache-dir \
    mlflow==2.8.1 \
    boto3 \
    psycopg2-binary \
    pymysql

# Create mlflow directories
RUN mkdir -p /mlflow/artifacts /mlflow/db

# Expose port
EXPOSE 5000

# Start MLflow server
CMD ["mlflow", "server", \
     "--backend-store-uri", "sqlite:///mlflow/mlflow.db", \
     "--default-artifact-root", "/mlflow/artifacts", \
     "--host", "0.0.0.0", \
     "--port", "5000"]

