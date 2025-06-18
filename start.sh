#!/bin/bash

echo "🚀 Starting AI Development Stack for Apple Silicon..."
echo "=============================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"

# Pull latest images from private registry if available
echo "📥 Pulling latest images from private registry..."
if ./scripts/pull-images.sh jupyter 2>/dev/null; then
    echo "✅ Images pulled from registry"
else
    echo "⚠️  Could not pull from registry, will build locally"
fi

# Start the services
echo "🔨 Starting services..."
docker-compose -f docker-compose-working.yml up -d

# Wait a moment for services to start
echo "⏳ Waiting for services to initialize..."
sleep 15

# Check service status
echo "📊 Service Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep ai-

echo ""
echo "🎉 AI Development Stack is ready!"
echo ""
echo "📍 Access your development environment:"
echo "   🎯 Jupyter Lab:  http://localhost:8889"
echo "   🔐 Token:        ai-dev-token"
echo "   🗄️  ChromaDB:     http://localhost:8000"
echo "   🔄 Redis:        localhost:6380"
echo ""
echo "📁 Your workspace directories:"
echo "   📊 Data:         ./data"
echo "   🤖 Models:       ./models" 
echo "   📓 Notebooks:    ./jupyter/notebooks"
echo "   🚀 Projects:     ./projects"
echo ""
echo "💡 To stop the stack: docker-compose -f docker-compose-working.yml down"
echo "🔄 To view logs:    docker-compose -f docker-compose-working.yml logs -f"

