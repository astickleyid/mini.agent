#!/bin/bash

# Open mini.agent Dashboard (brings to front)

cd "$(dirname "$0")"

# Kill any existing instance
pkill -f "MiniDashboard" 2>/dev/null

# Build if needed
if [ ! -f ".build/debug/MiniDashboard" ]; then
    echo "Building dashboard..."
    swift build --product MiniDashboard
fi

echo "🚀 Opening Dashboard..."

# Launch and bring to front
.build/debug/MiniDashboard &
DASHBOARD_PID=$!

# Wait a moment for it to start
sleep 2

# Activate the app (bring to front)
osascript -e 'tell application "System Events" to set frontmost of first process whose unix id is '$DASHBOARD_PID' to true' 2>/dev/null

echo "✅ Dashboard is now visible!"
echo ""
echo "Try the Configuration tab (or check what's there now)"
