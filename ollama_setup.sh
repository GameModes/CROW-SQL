#!/bin/bash

# Ollama installation script for Ubuntu
# This script installs Ollama and sets up initial configuration

echo "Installing Ollama for Ubuntu..."

# Download and install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

echo "Ollama installed successfully!"

echo "To run Ollama, you have two options:"
echo "1. Start Ollama service: systemctl --user start ollama (if available)"
echo "2. Or run directly: ollama serve (keep this terminal open)"

echo ""
echo "After starting Ollama, you can pull models like:"
echo "  ollama pull llama3"
echo "  ollama pull mistral"
echo "  ollama pull phi3"
echo ""
echo "To verify installation, after starting ollama serve in another terminal run:"
echo "  curl http://localhost:11434"
echo ""
echo "Check available models at: https://ollama.ai/library"