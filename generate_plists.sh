#!/usr/bin/env bash
set -euo pipefail

# Get user's home directory dynamically
HOME_DIR="$HOME"
AGENTS_DIR="$HOME_DIR/.mini/agents"
LOGS_DIR="$HOME_DIR/.mini/logs"

# List of agents
AGENTS=("builder" "debugger" "memory" "repo" "test" "terminalproxy" "supervisor")

echo "Generating LaunchAgent plists with dynamic paths..."

for agent in "${AGENTS[@]}"; do
    AGENT_NAME="mini.agent.$agent"
    PLIST_FILE="LaunchAgents/$AGENT_NAME.plist"
    
    # Capitalize first letter for binary name
    FIRST_CHAR=$(echo "$agent" | cut -c 1 | tr '[:lower:]' '[:upper:]')
    REST_CHARS=$(echo "$agent" | cut -c 2-)
    BINARY_NAME="${FIRST_CHAR}${REST_CHARS}Agent"
    
    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$AGENT_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>$AGENTS_DIR/$BINARY_NAME/$BINARY_NAME</string>
    </array>
    <key>MachServices</key>
    <dict>
        <key>$AGENT_NAME</key>
        <true/>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOGS_DIR/$agent/launchd.log</string>
    <key>StandardErrorPath</key>
    <string>$LOGS_DIR/$agent/launchd.err</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF
    
    echo "  ✓ Generated $PLIST_FILE"
done

echo "✅ All plist files generated successfully!"
