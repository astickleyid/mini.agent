# mini.agent Quick Start Guide

Get mini.agent up and running in 2 minutes with the simplified architecture!

## Prerequisites

- macOS 13.0 or later
- Swift 5.9 or later (usually comes with Xcode or Command Line Tools)

## Installation

### 1. Clone and Install

```bash
git clone <repository-url>
cd mini.agent
./install.sh
```

That's it! The script will:
- ✅ Create necessary directories
- ✅ Build the CLI tool with SwiftPM
- ✅ Install to `/usr/local/bin/mini`
- ✅ Create default configuration

### 2. Initialize Your Project

```bash
# Initialize current directory
mini init .

# Or specify a path
mini init /path/to/your/swift/project
```

### 3. Verify Installation

```bash
mini --version
mini config
```

## First Commands

```bash
# View git status
mini status

# Build your Swift project
mini build

# Run tests
mini test

# Create a commit
mini commit "Initial commit"

# Create a branch
mini branch "feature/awesome"

# Save a note
mini memory "Remember: refactor the parser"
```

## How It Works

The **simplified architecture** means:
- 🚀 **Instant**: No service startup delays
- 🎯 **Direct**: Agents run in-process using Swift actors
- 🛠️ **Simple**: Standard SwiftPM build, no XPC/launchd
- 🐛 **Easy**: Debug like any Swift app

## Troubleshooting

### Command Not Found

```bash
# Ensure installation completed
which mini

# If not found, check /usr/local/bin is in PATH
echo $PATH

# Reinstall if needed
./install.sh
```

### Build Errors

```bash
# Clean and rebuild
swift package clean
swift build -c release
./install.sh
```

## Configuration

Configuration is stored at `~/.mini/config.json`:

```json
{
  "projectPath": "/Users/you/.mini/projects/current",
  "logsPath": "/Users/you/.mini/logs",
  "memoryPath": "/Users/you/.mini/memory"
}
```

View with: `mini config`

## Common Workflows

### Quick Development Loop

```bash
cd ~/my-swift-project
mini init .
mini build
mini test
mini commit "Fixed bug X"
```

### Using Memory

```bash
# Save notes
mini memory "TODO: Update documentation"
mini memory "Bug: Parser fails on empty input"

# View saved notes (stored in ~/.mini/memory/)
ls ~/.mini/memory/
```

## What's Different?

### Old Architecture (XPC-based)
- ❌ Multiple processes via XPC services
- ❌ LaunchAgent plist management
- ❌ IPC serialization overhead
- ❌ Complex debugging

### New Architecture (Simplified)
- ✅ Single process with Swift actors
- ✅ Standard SwiftPM build
- ✅ Direct async/await calls
- ✅ Easy debugging

## Optional: SwiftUI Dashboard

Want a GUI? Open the Xcode project:

```bash
open mini-agent.xcodeproj
# Build and run the "Dashboard" scheme
```

The dashboard provides:
- Visual agent status
- Quick action buttons
- Real-time output display
- Interactive command forms

## Next Steps

1. Try all commands: `mini --help`
2. Read the [README](README.md) for architecture details
3. Check out the agents in `Sources/Agents/`
4. Customize agents for your workflow

## Summary

You now have:
- ✅ CLI installed and working
- ✅ Project initialized
- ✅ Configuration ready
- ✅ All agents available instantly

**No services to manage. No complexity. Just works.** 🎉
