"""
Jupyter Lab startup script for AI Dev Stack
"""

import os
import sys
import warnings
warnings.filterwarnings('ignore')

# Set up environment
os.environ['TOKENIZERS_PARALLELISM'] = 'false'

print("🚀 AI Dev Stack - Jupyter Lab")
print("=" * 50)
print("📁 Workspace: /workspace")
print("📊 Data: /workspace/data")
print("🤖 Models: /workspace/models")
print("📓 Notebooks: /workspace/notebooks")
print("🛠️  Projects: /workspace/projects")
print("=" * 50)
print("🌟 Ready for AI Development!")
print("Token: ai-dev-token")
print("=" * 50)

# Import commonly used libraries
try:
    import numpy as np
    import pandas as pd
    import matplotlib.pyplot as plt
    import seaborn as sns
    import torch
    import transformers
    print("✅ Core libraries imported successfully")
except ImportError as e:
    print(f"⚠️  Warning: {e}")

