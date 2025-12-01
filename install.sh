#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
BIN_DIR="$HOME/.mini/agents"
LAUNCH_DIR="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/.mini/logs"
MEMORY_DIR="$HOME/.mini/memory"
PROJECTS_DIR="$HOME/.mini/projects"

echo "🚀 Installing mini.agent..."

# Create necessary directories
mkdir -p "$BIN_DIR" "$LAUNCH_DIR" "$LOG_DIR" "$MEMORY_DIR" "$PROJECTS_DIR"

# Generate plist files with correct paths
echo "📝 Generating LaunchAgent plists..."
"$ROOT/generate_plists.sh"

# Build CLI
echo "🔨 Building CLI..."
pushd "$ROOT" >/dev/null
swift build -c release --product mini
sudo cp .build/release/mini /usr/local/bin/mini
popd >/dev/null

echo "✅ CLI installed to /usr/local/bin/mini"

# Initialize default configuration
echo "⚙️  Creating default configuration..."
mini init "$HOME/.mini/projects/current" 2>/dev/null || true

echo ""
echo "📦 Building XPC agents (this may take a few minutes)..."
echo "You can build agents using one of these methods:"
echo ""
echo "Option 1 - Swift Package Manager (recommended):"
echo "  swift build -c release"
echo ""
echo "Option 2 - Xcode (for GUI development):"
echo "  xcodebuild -scheme Agents -configuration Release"
echo ""
echo "After building, run this script again to install the agents."
echo ""

# Check if agents are already built
AGENTS_BUILT=true
for agent in BuilderAgent DebuggerAgent MemoryAgent RepoAgent TestAgent TerminalProxyAgent SupervisorAgent; do
    if [ ! -f ".build/release/$agent" ]; then
        AGENTS_BUILT=false
        break
    fi
done

if [ "$AGENTS_BUILT" = true ]; then
    echo "✅ Agents found in .build/release, copying to $BIN_DIR..."
    for agent in BuilderAgent DebuggerAgent MemoryAgent RepoAgent TestAgent TerminalProxyAgent SupervisorAgent; do
        mkdir -p "$BIN_DIR/$agent"
        cp ".build/release/$agent" "$BIN_DIR/$agent/$agent"
        echo "  ✓ Installed $agent"
    done
    
    echo ""
    echo "📋 Installing LaunchAgents..."
    cp "$ROOT"/LaunchAgents/mini.agent.*.plist "$LAUNCH_DIR"/
    
    echo "🔄 Reloading LaunchAgents..."
    launchctl unload "$LAUNCH_DIR"/mini.agent.*.plist 2>/dev/null || true
    launchctl load "$LAUNCH_DIR"/mini.agent.*.plist
    
    echo ""
    echo "✅ Installation complete!"
    echo ""
    echo "Available commands:"
    echo "  mini status      - Check system status"
    echo "  mini --help      - Show all commands"
    echo ""
    echo "Wait a few seconds for agents to start, then run: mini status"
else
    echo "⚠️  Agents not built yet. Build them first with: swift build -c release"
    echo "Then run this install script again."
fi
