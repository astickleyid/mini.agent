# mini.agent

**Simplified** local macOS multi-agent system using Swift Concurrency (async/await actors).

## Architecture

**v2.0 - Simplified Design:**
- ✅ No XPC services - direct async/await agent calls
- ✅ No launchd complexity - runs in-process
- ✅ Standard SwiftPM build system
- ✅ Single executable for CLI
- ✅ Optional SwiftUI dashboard

## Structure
- `Sources/MiniAgentCore/`: Core agent framework (Agent protocol, AgentManager, Configuration, Logger)
- `Sources/Agents/`: BuilderAgent, TestAgent, RepoAgent, MemoryAgent
- `Sources/CLI/`: Command-line client (`mini`)
- `Sources/Dashboard/`: SwiftUI dashboard (optional)
- `Package.swift`: Swift Package Manager manifest
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
mini status                 # Show git status
mini memory "note"          # Save a memory note
mini init [path]            # Initialize project (default: current dir)
mini config                 # Show configuration
mini --version, -v          # Show version
mini --help, -h             # Show this help
```

## Directory Structure
- CLI executable: `/usr/local/bin/mini`
- Logs: `~/.mini/logs/` (per-agent log files)
- Memory data: `~/.mini/memory/` (saved notes)
- Configuration: `~/.mini/config.json`
- Projects: `~/.mini/projects/current` (symlink to your project)

## Features

### Simplified Architecture
- **In-process agents**: Agents run directly within the CLI process using Swift actors
- **No IPC overhead**: Direct async/await calls, no XPC serialization
- **Instant startup**: No launchd services to manage
- **Easy debugging**: Standard Swift debugging, no multi-process complexity

### Core Capabilities
- **Build automation**: Swift package builds via BuilderAgent
- **Test execution**: Automated testing via TestAgent
- **Git operations**: Commit, branch, status via RepoAgent
- **Memory system**: Persistent note-taking via MemoryAgent
- **Configuration**: Dynamic path resolution using user's home directory

## Quick Test
1. `mini config` - View configuration
2. `mini status` - Check git status
3. `mini build` - Build project (if Swift package)
4. `mini test` - Run tests
5. `mini commit "initial"` - Create commit
6. `mini branch "dev"` - Create branch
7. `mini memory "first note"` - Save memory note

## Build Details
- **CLI + Agents**: Standard SwiftPM via `swift build -c release`
- **Dashboard** (optional): Build via Xcode for GUI development
- **Install**: Run `./install.sh` to build and install the CLI

## Why Simplified?

The previous architecture used XPC services and launchd for agent isolation, which added:
- Complex IPC serialization overhead
- Multi-process debugging challenges
- LaunchAgent plist management
- Service lifecycle complexity

The new architecture leverages Swift's modern concurrency model:
- **Actors** provide thread-safe agent isolation
- **Async/await** eliminates callback complexity
- **In-process** execution is faster and simpler
- **Standard tooling** for building and debugging

Perfect for local development workflows where isolation isn't critical and simplicity matters more.

## Documentation
- See [ANALYSIS.md](ANALYSIS.md) for legacy XPC architecture analysis
- See `_old_xpc_architecture/` for previous implementation reference
