# mini.agent Quick Start Guide

Get up and running with mini.agent in 5 minutes!

---

## Prerequisites

- macOS 13.0 or later
- Xcode Command Line Tools
- Swift 5.9+

```bash
# Install Xcode Command Line Tools if needed
xcode-select --install
```

---

## Installation

### Step 1: Build and Install

```bash
cd /path/to/mini.agent
./install.sh
```

This will:
- ✅ Create necessary directories in `~/.mini/`
- ✅ Generate LaunchAgent configuration files
- ✅ Build the CLI tool
- ✅ Install `mini` to `/usr/local/bin/`
- ✅ Create default configuration

### Step 2: Build the XPC Agents

The agents need to be built separately:

```bash
# Build all agents with Swift Package Manager
swift build -c release

# Or use Xcode for GUI development
open mini-agent.xcodeproj
# Then: Product → Build (⌘B)
```

### Step 3: Install Agents

Run the install script again to deploy the built agents:

```bash
./install.sh
```

This will:
- ✅ Copy agent binaries to `~/.mini/agents/`
- ✅ Load LaunchAgents (agents will auto-start)

### Step 4: Initialize Your Project

```bash
# Initialize with your project path
mini init /path/to/your/swift/project

# Or use current directory
cd /path/to/your/project
mini init .
```

---

## Verification

Check that everything is working:

```bash
# Check system status
mini status

# Should show all agents running
# Example output:
# 🔎 mini.agent System Status
# --------------------------------
# • Builder Agent: RUNNING
# • Debugger Agent: RUNNING
# • Memory Agent: RUNNING
# ...
```

---

## Basic Usage

### Build Your Project
```bash
mini build
```

### Run Tests
```bash
mini test
```

### Git Operations
```bash
# Create a commit
mini commit "Your commit message"

# Create a branch
mini branch feature/new-feature
```

### Execute Shell Commands
```bash
mini shell "echo Hello from mini.agent"
```

### Save Notes
```bash
mini memory "Remember to refactor the Parser class"
```

### View Logs
```bash
# List all agent logs
mini logs

# View specific agent log
mini logs builder
mini logs test
mini logs supervisor
```

### View Configuration
```bash
mini config
```

### Restart an Agent
```bash
mini restart builder
```

---

## Common Tasks

### Check System Health
```bash
mini status
```

### Troubleshoot Issues
```bash
# View all available agent logs
mini logs

# Check supervisor logs
mini logs supervisor

# Restart a problematic agent
mini restart <agent-name>

# Check configuration
mini config
```

### Change Project
```bash
# Switch to a different project
mini init /path/to/another/project
```

---

## Directory Structure

After installation, your `~/.mini/` directory will contain:

```
~/.mini/
├── agents/           # Agent binaries
│   ├── BuilderAgent/
│   ├── DebuggerAgent/
│   ├── MemoryAgent/
│   ├── RepoAgent/
│   ├── TestAgent/
│   ├── TerminalProxyAgent/
│   └── SupervisorAgent/
├── logs/            # Agent logs
│   ├── builder/
│   ├── debugger/
│   ├── memory/
│   ├── repo/
│   ├── test/
│   ├── terminalproxy/
│   └── supervisor/
├── memory/          # Memory notes
│   ├── summaries/
│   └── history/
├── projects/        # Project links
│   └── current/     # Symlink to your project
└── config.json      # Configuration file
```

---

## Available Commands

```
mini build                  # Build the current project
mini test                   # Run tests
mini commit "message"       # Create a git commit
mini branch "name"          # Create a new git branch
mini shell "command"        # Execute a shell command
mini memory "note"          # Save a memory note
mini status                 # Check system status
mini logs [agent]           # View agent logs
mini init [path]            # Initialize project
mini config                 # Show configuration
mini restart <agent>        # Restart an agent
mini --version, -v          # Show version
mini --help, -h             # Show this help
```

---

## Uninstall

To remove mini.agent:

```bash
# 1. Unload LaunchAgents
launchctl unload ~/Library/LaunchAgents/mini.agent.*.plist

# 2. Remove LaunchAgent plists
rm ~/Library/LaunchAgents/mini.agent.*.plist

# 3. Remove CLI tool
sudo rm /usr/local/bin/mini

# 4. Remove data (optional - includes logs and memory)
rm -rf ~/.mini
```

---

## Getting Help

- **Documentation:** See [README.md](README.md) for detailed information
- **Analysis:** See [ANALYSIS.md](ANALYSIS.md) for architecture details
- **Implementation:** See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for recent changes

### Common Issues

**"Failed to connect to agent"**
- Run `mini status` to check if agents are running
- Check logs: `mini logs supervisor`
- Try restarting: `mini restart <agent-name>`

**"Project not found"**
- Run `mini init /path/to/project` to set up your project
- Verify path: `mini config`

**"Timeout waiting for agent"**
- The operation may take longer than 30 seconds
- Check agent logs for issues: `mini logs <agent-name>`
- Restart the agent: `mini restart <agent-name>`

---

## Next Steps

1. **Try the Dashboard:** Open `MiniDashboard.app` for a GUI interface
2. **Explore Features:** Try all commands to get familiar
3. **Customize:** Edit `~/.mini/config.json` to customize paths
4. **Integrate:** Add `mini` commands to your development workflow

---

**Enjoy using mini.agent! 🚀**
