"""
FastAPI AI Model Serving API
Optimized for Apple Silicon Docker environment
"""

from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import torch
from transformers import pipeline, AutoTokenizer, AutoModel
from sentence_transformers import SentenceTransformer
import chromadb
import redis
import json
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="AI Dev Stack API",
    description="AI Model Serving API for Apple Silicon Docker Environment",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global models dictionary
models = {}

# Initialize connections
try:
    chroma_client = chromadb.HttpClient(host="vector-db", port=8000)
    redis_client = redis.Redis(host="redis", port=6379, decode_responses=True)
    logger.info("✅ Connected to ChromaDB and Redis")
except Exception as e:
    logger.warning(f"⚠️ Connection warning: {e}")
    chroma_client = None
    redis_client = None

# Pydantic models
class TextInput(BaseModel):
    text: str
    model_name: Optional[str] = "default"

class TextResponse(BaseModel):
    result: Any
    model_used: str
    timestamp: str

class EmbeddingRequest(BaseModel):
    texts: List[str]
    model_name: Optional[str] = "all-MiniLM-L6-v2"

class ModelInfo(BaseModel):
    name: str
    type: str
    status: str
    loaded_at: Optional[str] = None

@app.on_event("startup")
async def startup_event():
    """Load default models on startup"""
    logger.info("🚀 Starting AI Dev Stack API...")
    
    # Load default sentence transformer
    try:
        models["embeddings"] = SentenceTransformer('all-MiniLM-L6-v2')
        logger.info("✅ Loaded sentence transformer model")
    except Exception as e:
        logger.error(f"❌ Failed to load embeddings model: {e}")
    
    # Load default text generation pipeline
    try:
        models["text_generator"] = pipeline(
            "text-generation",
            model="distilgpt2",
            torch_dtype=torch.float32 if torch.backends.mps.is_available() else torch.float32
        )
        logger.info("✅ Loaded text generation model")
    except Exception as e:
        logger.error(f"❌ Failed to load text generation model: {e}")

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "AI Dev Stack API",
        "version": "1.0.0",
        "platform": "Apple Silicon Docker",
        "endpoints": {
            "health": "/health",
            "models": "/models",
            "generate": "/generate",
            "embeddings": "/embeddings",
            "similarity": "/similarity"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "models_loaded": len(models),
        "chromadb_connected": chroma_client is not None,
        "redis_connected": redis_client is not None
    }

@app.get("/models", response_model=List[ModelInfo])
async def list_models():
    """List all loaded models"""
    model_list = []
    for name, model in models.items():
        model_list.append(ModelInfo(
            name=name,
            type=type(model).__name__,
            status="loaded",
            loaded_at=datetime.now().isoformat()
        ))
    return model_list

@app.post("/generate", response_model=TextResponse)
async def generate_text(request: TextInput):
    """Generate text using loaded models"""
    if "text_generator" not in models:
        raise HTTPException(status_code=503, detail="Text generation model not available")
    
    try:
        result = models["text_generator"](
            request.text, 
            max_length=100, 
            num_return_sequences=1,
            temperature=0.7
        )
        
        return TextResponse(
            result=result[0]["generated_text"],
            model_used="distilgpt2",
            timestamp=datetime.now().isoformat()
        )
    except Exception as e:
        logger.error(f"Generation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/embeddings")
async def create_embeddings(request: EmbeddingRequest):
    """Create embeddings for input texts"""
    if "embeddings" not in models:
        raise HTTPException(status_code=503, detail="Embeddings model not available")
    
    try:
        embeddings = models["embeddings"].encode(request.texts)
        return {
            "embeddings": embeddings.tolist(),
            "model_used": request.model_name,
            "count": len(request.texts),
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        logger.error(f"Embeddings error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/similarity")
async def compute_similarity(text1: str, text2: str):
    """Compute similarity between two texts"""
    if "embeddings" not in models:
        raise HTTPException(status_code=503, detail="Embeddings model not available")
    
    try:
        embeddings = models["embeddings"].encode([text1, text2])
        similarity = torch.nn.functional.cosine_similarity(
            torch.tensor(embeddings[0]).unsqueeze(0),
            torch.tensor(embeddings[1]).unsqueeze(0)
        ).item()
        
        return {
            "similarity": similarity,
            "text1": text1,
            "text2": text2,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        logger.error(f"Similarity error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/upload-model")
async def upload_model(file: UploadFile = File(...)):
    """Upload and load a new model"""
    # This is a placeholder for model upload functionality
    return {
        "message": f"Model upload functionality - received {file.filename}",
        "note": "Implement model loading logic based on your needs"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

