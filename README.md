# mini.agent

Local macOS multi-agent environment using XPC services, CLI, and a SwiftUI dashboard.

## Structure
- `XPCShared/`: Shared protocol + logger + JSON coders + configuration system
- `Agents/`: Builder, Debugger, Memory, Repo, Test, TerminalProxy, Supervisor XPC services
- `CLI/mini`: Command-line client (`mini`)
- `macOSApp/`: SwiftUI dashboard
- `LaunchAgents/`: `launchd` plists for each agent
- `install.sh`: Automated build/install script

## Installation

```bash
# 1. Build and install
./install.sh

# 2. Initialize your project
mini init /path/to/your/project

# 3. Check status
mini status
```

## Commands (CLI)
```bash
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

## Directory Structure
- CLI install: `/usr/local/bin/mini`
- Agents runtime: `~/.mini/agents/<AgentName>`
- Logs: `~/.mini/logs/<agent>/`
- Memory data: `~/.mini/memory/`
- Configuration: `~/.mini/config.json`
- Projects: `~/.mini/projects/current` (symlink)

## Features

### Dynamic Configuration
All paths are now dynamically resolved using the user's home directory. No hardcoded paths!

### Enhanced Error Handling
- Connection timeouts (30s default)
- Descriptive error messages
- Graceful degradation

### Agent Management
- Health monitoring via SupervisorAgent
- Automatic restart on failure
- Individual agent restart capability

## Smoke Tests
1. `mini status` - Check all agents are running
2. `mini config` - View configuration
3. `mini logs supervisor` - View supervisor logs
4. `mini build` - Build project
5. `mini test` - Run tests
6. `mini commit "initial"` - Create commit
7. `mini branch "dev"` - Create branch
8. `mini memory "first note"` - Save memory

## Build Details
- **XPC services + dashboard**: via Xcode targets (mach services `mini.agent.<name>`)
- **CLI**: via `swift build -c release`
- **Install**: via `./install.sh` (copies binaries, generates & loads plists)

## Documentation
See [ANALYSIS.md](ANALYSIS.md) for comprehensive codebase analysis and architecture details.
