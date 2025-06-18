"""
AI Dev Stack - Streamlit Prototyping Interface
"""

import streamlit as st
import requests
import pandas as pd
import plotly.express as px
import numpy as np
from datetime import datetime
import json

# Configure page
st.set_page_config(
    page_title="AI Dev Stack",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# API endpoints
API_BASE = "http://api-server:8000"

def main():
    st.title("🤖 AI Development Stack")
    st.markdown("### Apple Silicon Docker Environment")
    
    # Sidebar
    st.sidebar.title("🛠️ Tools")
    page = st.sidebar.selectbox(
        "Choose a tool:",
        ["🏠 Dashboard", "📝 Text Generation", "🔍 Embeddings", "📊 Model Analytics", "⚙️ API Status"]
    )
    
    if page == "🏠 Dashboard":
        show_dashboard()
    elif page == "📝 Text Generation":
        show_text_generation()
    elif page == "🔍 Embeddings":
        show_embeddings()
    elif page == "📊 Model Analytics":
        show_analytics()
    elif page == "⚙️ API Status":
        show_api_status()

def show_dashboard():
    st.header("🏠 AI Development Dashboard")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.metric("🚀 Status", "Online", "✅")
    
    with col2:
        st.metric("🤖 Models", "2", "+2")
    
    with col3:
        st.metric("📦 Platform", "Apple Silicon", "ARM64")
    
    st.markdown("---")
    
    # Quick links
    st.subheader("🔗 Quick Access")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("🎯 Jupyter Lab"):
            st.info("Open: http://localhost:8888 (Token: ai-dev-token)")
    
    with col2:
        if st.button("📡 API Docs"):
            st.info("Open: http://localhost:8000/docs")
    
    with col3:
        if st.button("📊 MLflow"):
            st.info("Open: http://localhost:5000")
    
    # Recent activity
    st.subheader("📈 System Overview")
    
    # Generate sample data
    dates = pd.date_range(start="2024-01-01", end="2024-01-30", freq="D")
    usage = np.random.randint(20, 100, len(dates))
    
    df = pd.DataFrame({
        "Date": dates,
        "CPU Usage": usage,
        "Memory Usage": np.random.randint(30, 80, len(dates))
    })
    
    fig = px.line(df, x="Date", y=["CPU Usage", "Memory Usage"], 
                  title="System Performance (Mock Data)")
    st.plotly_chart(fig, use_container_width=True)

def show_text_generation():
    st.header("📝 Text Generation")
    
    # Input
    user_input = st.text_area(
        "Enter your prompt:",
        placeholder="Once upon a time...",
        height=100
    )
    
    col1, col2 = st.columns([1, 4])
    
    with col1:
        if st.button("🚀 Generate", type="primary"):
            if user_input:
                with st.spinner("Generating text..."):
                    try:
                        response = requests.post(
                            f"{API_BASE}/generate",
                            json={"text": user_input},
                            timeout=30
                        )
                        
                        if response.status_code == 200:
                            result = response.json()
                            st.success("✅ Generation complete!")
                            st.text_area(
                                "Generated Text:",
                                value=result["result"],
                                height=200,
                                disabled=True
                            )
                            
                            # Show metadata
                            with st.expander("📊 Generation Details"):
                                st.json(result)
                        else:
                            st.error(f"❌ Error: {response.status_code}")
                    
                    except requests.exceptions.RequestException as e:
                        st.error(f"❌ Connection error: {e}")
                        st.info("💡 Make sure the API server is running")
            else:
                st.warning("⚠️ Please enter a prompt")

def show_embeddings():
    st.header("🔍 Text Embeddings & Similarity")
    
    tab1, tab2 = st.tabs(["📊 Create Embeddings", "🔍 Similarity Check"])
    
    with tab1:
        st.subheader("Create Embeddings")
        
        texts = st.text_area(
            "Enter texts (one per line):",
            placeholder="Hello world\nAI is amazing\nApple Silicon rocks",
            height=100
        )
        
        if st.button("🔢 Generate Embeddings"):
            if texts:
                text_list = [t.strip() for t in texts.split('\n') if t.strip()]
                
                with st.spinner("Creating embeddings..."):
                    try:
                        response = requests.post(
                            f"{API_BASE}/embeddings",
                            json={"texts": text_list},
                            timeout=30
                        )
                        
                        if response.status_code == 200:
                            result = response.json()
                            st.success(f"✅ Created {result['count']} embeddings")
                            
                            # Show embeddings shape
                            embeddings = np.array(result['embeddings'])
                            st.info(f"📏 Shape: {embeddings.shape}")
                            
                            # Show first few dimensions
                            if len(embeddings) > 0:
                                df = pd.DataFrame(embeddings[:, :5], 
                                                columns=[f"Dim_{i}" for i in range(5)])
                                df.index = text_list[:len(df)]
                                st.dataframe(df)
                        else:
                            st.error(f"❌ Error: {response.status_code}")
                    
                    except requests.exceptions.RequestException as e:
                        st.error(f"❌ Connection error: {e}")
    
    with tab2:
        st.subheader("Similarity Check")
        
        col1, col2 = st.columns(2)
        
        with col1:
            text1 = st.text_area("Text 1:", height=100)
        
        with col2:
            text2 = st.text_area("Text 2:", height=100)
        
        if st.button("🎯 Calculate Similarity"):
            if text1 and text2:
                with st.spinner("Calculating similarity..."):
                    try:
                        response = requests.post(
                            f"{API_BASE}/similarity",
                            params={"text1": text1, "text2": text2},
                            timeout=30
                        )
                        
                        if response.status_code == 200:
                            result = response.json()
                            similarity = result["similarity"]
                            
                            st.metric("🎯 Cosine Similarity", f"{similarity:.4f}")
                            
                            # Visual indicator
                            if similarity > 0.8:
                                st.success("🟢 Very Similar")
                            elif similarity > 0.5:
                                st.info("🟡 Moderately Similar")
                            else:
                                st.warning("🔴 Not Very Similar")
                        else:
                            st.error(f"❌ Error: {response.status_code}")
                    
                    except requests.exceptions.RequestException as e:
                        st.error(f"❌ Connection error: {e}")

def show_analytics():
    st.header("📊 Model Analytics")
    st.info("🚧 Analytics dashboard coming soon!")
    
    # Placeholder analytics
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("📈 Model Performance")
        
        # Mock performance data
        models = ["DistilGPT2", "MiniLM-L6", "Custom Model"]
        performance = [0.85, 0.92, 0.78]
        
        df = pd.DataFrame({
            "Model": models,
            "Performance": performance
        })
        
        fig = px.bar(df, x="Model", y="Performance", title="Model Performance Scores")
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        st.subheader("⏱️ Response Times")
        
        # Mock response time data
        times = pd.date_range(start="2024-01-01", periods=10, freq="H")
        response_times = np.random.normal(200, 50, 10)
        
        df = pd.DataFrame({
            "Time": times,
            "Response Time (ms)": response_times
        })
        
        fig = px.line(df, x="Time", y="Response Time (ms)", title="API Response Times")
        st.plotly_chart(fig, use_container_width=True)

def show_api_status():
    st.header("⚙️ API Status & Health")
    
    if st.button("🔄 Refresh Status"):
        st.rerun()
    
    try:
        # Check API health
        response = requests.get(f"{API_BASE}/health", timeout=5)
        
        if response.status_code == 200:
            health_data = response.json()
            
            st.success("✅ API is healthy!")
            
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric("🤖 Models Loaded", health_data.get("models_loaded", 0))
            
            with col2:
                chroma_status = "✅" if health_data.get("chromadb_connected") else "❌"
                st.metric("🗄️ ChromaDB", chroma_status)
            
            with col3:
                redis_status = "✅" if health_data.get("redis_connected") else "❌"
                st.metric("🔄 Redis", redis_status)
            
            # Show full health data
            with st.expander("📋 Full Health Report"):
                st.json(health_data)
            
            # List available models
            try:
                models_response = requests.get(f"{API_BASE}/models", timeout=5)
                if models_response.status_code == 200:
                    models_data = models_response.json()
                    
                    st.subheader("🤖 Available Models")
                    
                    for model in models_data:
                        with st.container():
                            col1, col2, col3 = st.columns(3)
                            
                            with col1:
                                st.write(f"**{model['name']}**")
                            
                            with col2:
                                st.write(model['type'])
                            
                            with col3:
                                st.write("🟢 Active")
            
            except requests.exceptions.RequestException:
                st.warning("⚠️ Could not fetch model information")
        
        else:
            st.error(f"❌ API returned status code: {response.status_code}")
    
    except requests.exceptions.RequestException as e:
        st.error(f"❌ Could not connect to API: {e}")
        st.info("💡 Make sure Docker containers are running")

if __name__ == "__main__":
    main()

