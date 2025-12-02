#!/bin/bash

# Launch mini.agent Dashboard

cd "$(dirname "$0")"

echo "🚀 Launching mini.agent Dashboard..."

# Build if needed
if [ ! -f ".build/release/mini" ]; then
    echo "Building..."
    swift build -c release
fi

# Open the Dashboard app
if [ -d "MiniDashboard.app" ]; then
    open MiniDashboard.app
else
    echo "Dashboard app not found. Building..."
    ./create_app_bundle.sh
    open MiniDashboard.app
fi

echo "✅ Dashboard launched!"
echo ""
echo "💡 Try the Configuration tab to:"
echo "   - Enable AI tools (Copilot, Gemini, OpenAI, Ollama)"
echo "   - Create custom commands"
echo "   - Set routing preferences"
echo ""
echo "CLI syncs automatically with GUI settings"
