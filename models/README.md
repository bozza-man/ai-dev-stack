# 🤖 Models Directory

This directory stores your trained AI models and artifacts.

## 📁 Structure

```
models/
├── trained/          # Your custom trained models
├── pretrained/       # Downloaded pre-trained models
├── checkpoints/      # Training checkpoints
└── exports/          # Exported/converted models
```

## 🏷️ Model Organization

### Naming Convention
```
{model_type}_{version}_{date}.{extension}

Examples:
- sentiment_classifier_v1_2025-06-18.pkl
- embeddings_model_v2_2025-06-18.joblib
- custom_transformer_v1_2025-06-18/
```

### Supported Formats
- **PyTorch**: `.pt`, `.pth`
- **TensorFlow**: `.h5`, `.pb`, SavedModel directories
- **Scikit-learn**: `.pkl`, `.joblib`
- **Transformers**: Model directories with config.json
- **ONNX**: `.onnx`
- **MLflow**: MLmodel format

## 🚀 Usage in Containers

Models in this directory are automatically mounted to:
- **Jupyter**: `/workspace/models`
- **API Server**: `/app/models`
- **Streamlit**: `/app/models`

## 🔒 Security Note

- Large model files are ignored by Git (see .gitignore)
- Use Git LFS for models you want to version
- Store sensitive models in secure registries
- Consider using MLflow Model Registry for production

## 📊 MLflow Integration

Register models with MLflow for versioning and deployment:

```python
import mlflow
import mlflow.sklearn

# Log model
mlflow.sklearn.log_model(model, "model")

# Register model
mlflow.register_model("runs:/{run_id}/model", "MyModel")
```

## 🔗 External Model Storage

For large models, consider:
- **Hugging Face Hub**: `transformers.AutoModel.from_pretrained()`
- **AWS S3**: Store and download as needed
- **Google Cloud Storage**: For TensorFlow models
- **MLflow Artifact Store**: Centralized model storage

Happy modeling! 🚀

