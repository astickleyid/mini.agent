#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
LOG_DIR="$HOME/.mini/logs"
MEMORY_DIR="$HOME/.mini/memory"
PROJECTS_DIR="$HOME/.mini/projects"
CONFIG_DIR="$HOME/.mini"

echo "🚀 Installing mini.agent (Simplified Architecture)..."
echo ""

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p "$LOG_DIR" "$MEMORY_DIR" "$PROJECTS_DIR" "$CONFIG_DIR"

# Build CLI
echo ""
echo "🔨 Building CLI..."
pushd "$ROOT" >/dev/null
swift build -c release --product mini
popd >/dev/null

# Install CLI
echo ""
echo "📦 Installing CLI to /usr/local/bin/mini..."
if [ -w "/usr/local/bin" ]; then
    cp .build/release/mini /usr/local/bin/mini
else
    echo "   (requires sudo permission)"
    sudo cp .build/release/mini /usr/local/bin/mini
fi
chmod +x /usr/local/bin/mini

# Create default configuration
echo ""
echo "⚙️  Creating default configuration..."
cat > "$CONFIG_DIR/config.json" <<EOF
{
  "projectPath": "$HOME/.mini/projects/current",
  "logsPath": "$HOME/.mini/logs",
  "memoryPath": "$HOME/.mini/memory"
}
EOF

echo ""
echo "✅ Installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  mini.agent - Simplified Architecture"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Key improvements:"
echo "  ✓ No XPC services - direct async/await agent calls"
echo "  ✓ No launchd complexity - runs in-process"
echo "  ✓ Standard SwiftPM build system"
echo "  ✓ Single executable for CLI"
echo ""
echo "Available commands:"
echo "  mini build              - Build your project"
echo "  mini test               - Run tests"
echo "  mini commit \"msg\"       - Git commit"
echo "  mini branch \"name\"      - Create branch"
echo "  mini status             - Git status"
echo "  mini memory \"note\"      - Save note"
echo "  mini config             - Show configuration"
echo "  mini --help             - Show help"
echo ""
echo "Next steps:"
echo "  1. Initialize your project:"
echo "     mini init /path/to/your/project"
echo ""
echo "  2. Or create a symlink manually:"
echo "     ln -s /path/to/your/project $HOME/.mini/projects/current"
echo ""
echo "  3. Try it out:"
echo "     mini status"
echo ""
