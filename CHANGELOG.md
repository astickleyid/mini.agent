# Changelog

All notable changes to mini.agent will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2025-12-01

### 🎉 Initial Release

First production-ready release of mini.agent with comprehensive improvements for portability, reliability, and usability.

### ✨ Added

#### Core Features
- **Configuration System** - `MiniConfiguration` for managing system settings
  - JSON-based configuration at `~/.mini/config.json`
  - Default configuration with sensible defaults
  - Load/save functionality
  
- **Enhanced Error Handling** - `AgentError` enum with descriptive messages
  - Connection failure detection
  - Timeout handling (30 second default)
  - Invalid response detection
  - Project not found errors
  - General operation failures

- **Dynamic Path Resolution** - All paths now use `FileManager` APIs
  - No hardcoded user paths
  - Portable across different macOS users
  - Proper use of home directory resolution

#### New CLI Commands
- `mini logs [agent]` - View agent logs (all or specific agent)
- `mini init [path]` - Initialize project with configuration
- `mini config` - Display current configuration
- `mini restart <agent>` - Restart a specific agent
- `mini --version, -v` - Show version information
- `mini --help, -h` - Display help text

#### New Agent Capabilities
- SupervisorAgent now handles restart requests
- Extended `AgentRequestType` with `.logs`, `.restart`, `.repoStatus`

#### Infrastructure
- `generate_plists.sh` - Automated LaunchAgent plist generation
  - Dynamic path substitution
  - Supports all 7 agents
  - User-specific configuration
  
#### Documentation
- `ANALYSIS.md` - Comprehensive codebase analysis (12KB)
- `IMPLEMENTATION_SUMMARY.md` - Detailed implementation notes (10KB)
- `QUICKSTART.md` - Quick start guide for new users (5KB)
- `CHANGELOG.md` - This file
- Enhanced `README.md` with complete command reference

### 🔧 Changed

- **Logger** - Now uses dynamic path resolution instead of hardcoded paths
- **BuilderLogic** - Dynamic project path with initialization
- **RepoLogic** - Dynamic project path with initialization
- **MiniClient (CLI)** - Enhanced with timeout and better error handling
- **MiniClient (Dashboard)** - Extended service routing for new request types
- **CommandRouter** - Complete rewrite with new command handlers
- **install.sh** - Major enhancement with automation and user guidance
  - Automatic directory creation
  - Plist generation
  - Configuration initialization
  - Better status messages
  - Conditional agent installation
  
### 🐛 Fixed

- XPC connection timeout issues (now has 30s timeout)
- Hardcoded path portability problems
- Missing error messages for common failures
- Silent connection failures
- Non-exhaustive switch statements in service routing

### 🏗️ Technical Details

#### Modified Files (11)
- `XPCShared/Logger.swift`
- `XPCShared/AgentRequest.swift`
- `CLI/mini/CommandRouter.swift`
- `CLI/mini/MiniClient.swift`
- `macOSApp/MiniClient.swift`
- `Agents/BuilderAgent/Sources/BuilderAgent/BuilderLogic.swift`
- `Agents/RepoAgent/Sources/RepoAgent/RepoLogic.swift`
- `Agents/SupervisorAgent/Sources/SupervisorAgent/SupervisorAgentService.swift`
- `install.sh`
- `README.md`
- All 7 `LaunchAgents/*.plist` files

#### New Files (7)
- `XPCShared/Configuration.swift`
- `XPCShared/AgentError.swift`
- `generate_plists.sh`
- `ANALYSIS.md`
- `IMPLEMENTATION_SUMMARY.md`
- `QUICKSTART.md`
- `CHANGELOG.md`

### 📊 Statistics
- **Lines Added:** ~800
- **Lines Modified:** ~150
- **Files Created:** 7
- **Files Modified:** 11
- **Documentation:** 1,197 lines across 4 markdown files

### 🧪 Testing
- ✅ Debug build successful
- ✅ Release build successful
- ✅ CLI commands functional
- ✅ No compilation errors
- ✅ Proper error handling verified

### ⚠️ Known Limitations
- Unit tests not yet implemented (Priority 3)
- Real-time dashboard updates not implemented (Priority 2)
- Dashboard log viewer not implemented (Priority 2)
- No CI/CD pipeline yet (Priority 3)

### 📝 Migration Notes

For existing installations:
1. Run `./generate_plists.sh` to update LaunchAgent plists
2. Run `./install.sh` to reinstall with new features
3. Run `mini init <path>` to configure your project
4. Existing logs and memory data are preserved

### 🎯 Next Steps

See [ANALYSIS.md](ANALYSIS.md) for:
- Priority 2: Enhanced Functionality
- Priority 3: Developer Experience
- Long-term architectural improvements

---

## [0.1.0] - 2024-11-29

### Initial Development Version
- Basic XPC agent architecture
- CLI with core commands (build, test, commit, branch, shell, memory, status)
- SwiftUI dashboard
- 7 specialized agents (Builder, Debugger, Memory, Repo, Test, TerminalProxy, Supervisor)
- LaunchAgent integration
- Basic logging

---

[1.0.0]: https://github.com/yourusername/mini.agent/releases/tag/v1.0.0
[0.1.0]: https://github.com/yourusername/mini.agent/releases/tag/v0.1.0
