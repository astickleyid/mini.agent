#!/usr/bin/env bash
set -e

APP_NAME="MiniDashboard"
BUNDLE_DIR="$APP_NAME.app"
CONTENTS="$BUNDLE_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "Creating macOS app bundle..."

# Clean old bundle
rm -rf "$BUNDLE_DIR"

# Create bundle structure
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable
cp .build/debug/MiniDashboard "$MACOS/$APP_NAME"

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MiniDashboard</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>mini.agent.dashboard</string>
    <key>CFBundleName</key>
    <string>Mini Dashboard</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "✅ App bundle created: $BUNDLE_DIR"
echo ""
echo "To run the app:"
echo "  open $BUNDLE_DIR"
echo ""
echo "Or double-click $BUNDLE_DIR in Finder"



#Preview {
    Text("Preview")
}
