# mini.agent Codebase Analysis

**Date:** 2025-12-01  
**Version:** 1.0  
**Status:** Initial Analysis

---

## Executive Summary

`mini.agent` is a local macOS multi-agent system built on XPC services that provides developer tools through a CLI (`mini`) and SwiftUI dashboard. The system orchestrates 7 specialized agents for building, testing, debugging, memory management, repository operations, terminal proxy, and supervision.

**Architecture:** XPC-based microservices pattern with launchd management  
**Platform:** macOS 13.0+  
**Language:** Swift 5.9+  
**Build System:** SwiftPM + XcodeGen

---

## System Architecture

### Core Components

1. **XPCShared Framework** - Shared protocols and utilities
   - `AgentXPCProtocol` - Service interface
   - `AgentRequest/Response` - Message types with NSSecureCoding
   - `Logger` - File-based logging to `~/.mini/logs/`
   - JSON encoders/decoders

2. **CLI (`mini`)** - Command-line interface
   - `CommandRouter` - Maps commands to agent requests
   - `MiniClient` - XPC connection manager
   - Installs to `/usr/local/bin/mini`

3. **Dashboard (MiniDashboardApp)** - SwiftUI GUI
   - `DashboardView` - Main UI with status panels
   - `DashboardModel` - State management
   - `TerminalPanel` - Command execution view
   - `FirstRunWizard` - Setup wizard

4. **Seven XPC Agents** - Each runs as launchd service
   - BuilderAgent - Swift package builds
   - TestAgent - Test execution
   - DebuggerAgent - Crash log analysis
   - RepoAgent - Git operations
   - MemoryAgent - Note persistence
   - TerminalProxyAgent - Shell command filtering
   - SupervisorAgent - Health monitoring & restart

### Directory Structure
```
mini.agent/
├── XPCShared/           # Shared framework
├── CLI/mini/            # Command-line tool
├── macOSApp/            # SwiftUI dashboard
├── Agents/              # 7 XPC service implementations
│   ├── BuilderAgent/
│   ├── TestAgent/
│   ├── DebuggerAgent/
│   ├── RepoAgent/
│   ├── MemoryAgent/
│   ├── TerminalProxyAgent/
│   └── SupervisorAgent/
├── LaunchAgents/        # launchd plists
├── Package.swift        # SPM manifest
├── project.yml          # XcodeGen config
└── install.sh           # Installation script
```

---

## Current State Assessment

### ✅ Strengths

1. **Clean Architecture** - Well-separated concerns with XPC boundaries
2. **Proper IPC** - NSSecureCoding compliance for security
3. **Persistent Agents** - launchd KeepAlive ensures reliability
4. **Dual Interface** - Both CLI and GUI access
5. **Comprehensive Logging** - Per-agent log files
6. **Self-Healing** - SupervisorAgent monitors and restarts failed services

### ⚠️ Issues & Gaps

#### Critical Issues

1. **Hardcoded User Paths**
   - `Logger.swift:6` - `/Users/austinstickley/.mini/logs`
   - `BuilderLogic.swift:10` - `/Users/austinstickley/.mini/projects/current`
   - `RepoLogic.swift:7` - Same hardcoded path
   - **Impact:** Non-portable, breaks for other users

2. **No Error Handling**
   - `MiniClient.swift:12` - XPC connection failures silently fail
   - Force unwraps in file operations
   - No timeout handling for long-running operations

3. **Missing Configuration**
   - No config file for project paths
   - No environment variable support
   - Agent settings embedded in code

4. **Incomplete Test Coverage**
   - No unit tests found
   - No integration tests
   - No CI/CD setup

#### Design Concerns

1. **Tight Coupling**
   - Agents directly depend on specific file paths
   - No dependency injection
   - No interface abstraction layers

2. **Limited CLI Commands**
   - Missing: `mini logs`, `mini config`, `mini init`
   - No `--help` flag support
   - No `--version` flag

3. **Dashboard Limitations**
   - Static status indicators (no real-time updates)
   - No log viewer
   - No configuration panel
   - No agent restart controls

4. **Security**
   - Terminal proxy has basic command filtering but could be enhanced
   - No authentication between CLI and agents
   - No rate limiting on XPC calls

5. **Observability**
   - Logs are plain text (no structured logging)
   - No metrics collection
   - No distributed tracing
   - No alerting

---

## Immediate Implementation Recommendations

### Priority 1: Critical Fixes (Required)

#### 1.1 Dynamic Path Resolution
**Problem:** Hardcoded user paths break portability  
**Solution:** Use `FileManager.default.homeDirectoryForCurrentUser`  

**Files to modify:**
- `XPCShared/Logger.swift` - Line 6
- `Agents/BuilderAgent/Sources/BuilderAgent/BuilderLogic.swift` - Line 10
- `Agents/RepoAgent/Sources/RepoAgent/RepoLogic.swift` - Line 7
- All LaunchAgents `.plist` files (use `~` instead of absolute paths)

**Implementation:**
```swift
// Before
private let logDirectory = "/Users/austinstickley/.mini/logs"

// After
private let logDirectory = FileManager.default
    .homeDirectoryForCurrentUser
    .appendingPathComponent(".mini/logs")
    .path
```

#### 1.2 Configuration System
**Problem:** No way to configure project paths or agent settings  
**Solution:** Create `~/.mini/config.json`  

**New file:** `XPCShared/Configuration.swift`
```swift
public struct MiniConfiguration: Codable {
    public let projectPath: String
    public let logsPath: String
    public let memoryPath: String
    public let agentsPath: String
    
    public static var `default`: MiniConfiguration {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return MiniConfiguration(
            projectPath: "\(home)/.mini/projects/current",
            logsPath: "\(home)/.mini/logs",
            memoryPath: "\(home)/.mini/memory",
            agentsPath: "\(home)/.mini/agents"
        )
    }
    
    public static func load() -> MiniConfiguration {
        let configPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/config.json")
            .path
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let config = try? sharedJSONDecoder.decode(MiniConfiguration.self, from: data) else {
            return .default
        }
        return config
    }
}
```

#### 1.3 Enhanced Error Handling
**Problem:** Silent failures, no user feedback  
**Solution:** Proper error types and recovery  

**New file:** `XPCShared/AgentError.swift`
```swift
public enum AgentError: Error, CustomStringConvertible {
    case connectionFailed(service: String)
    case timeout(service: String)
    case invalidResponse
    case projectNotFound(path: String)
    case operationFailed(reason: String)
    
    public var description: String {
        switch self {
        case .connectionFailed(let service):
            return "❌ Failed to connect to \(service). Is it running?"
        case .timeout(let service):
            return "⏱️ Timeout waiting for \(service)"
        case .invalidResponse:
            return "❌ Received invalid response from agent"
        case .projectNotFound(let path):
            return "📁 Project not found at: \(path)"
        case .operationFailed(let reason):
            return "❌ Operation failed: \(reason)"
        }
    }
}
```

**Modify:** `CLI/mini/MiniClient.swift`
```swift
func send(_ type: AgentRequestType, payload: String? = nil) -> String {
    let request = AgentRequest(type: type, payload: payload)
    let serviceName = resolveService(for: type)
    
    guard let conn = NSXPCConnection(machServiceName: serviceName, options: []) else {
        return AgentError.connectionFailed(service: serviceName).description
    }
    
    conn.remoteObjectInterface = NSXPCInterface(with: AgentXPCProtocol.self)
    conn.resume()
    
    let sem = DispatchSemaphore(value: 0)
    var result = "No response."
    
    if let proxy = conn.remoteObjectProxy as? AgentXPCProtocol {
        proxy.handle(request) { response in
            if let o = response.output { result = o }
            else if let e = response.error { result = e }
            else { result = AgentError.invalidResponse.description }
            sem.signal()
        }
    } else {
        return AgentError.connectionFailed(service: serviceName).description
    }
    
    // Add timeout
    if sem.wait(timeout: .now() + 30) == .timedOut {
        return AgentError.timeout(service: serviceName).description
    }
    
    conn.invalidate()
    return result
}
```

### Priority 2: Enhanced Functionality (High Value)

#### 2.1 Add Missing CLI Commands
**New commands needed:**
- `mini logs [agent]` - View agent logs
- `mini init [path]` - Initialize a project
- `mini config` - Show/edit configuration
- `mini restart [agent]` - Restart specific agent
- `mini --version` - Show version info
- `mini --help` - Show help

**Modify:** `CLI/mini/CommandRouter.swift`

#### 2.2 Real-time Dashboard Updates
**Problem:** Status is static  
**Solution:** Add polling/observer pattern  

**Modify:** `macOSApp/DashboardModel.swift` - Add Timer for periodic refresh

#### 2.3 Installation Improvements
**Problem:** Manual Xcode build required  
**Solution:** Automate full build in install.sh  

**Modify:** `install.sh` - Add Xcode build commands

### Priority 3: Developer Experience (Quality of Life)

#### 3.1 Structured Logging
**Enhancement:** JSON logs with log levels, timestamps, correlation IDs  
**Benefit:** Better debugging, potential integration with log aggregators

#### 3.2 Add Unit Tests
**Coverage:**
- XPCShared utilities
- CommandRouter logic
- Parser implementations (CompileDiagnosticsParser, TestOutputParser)

#### 3.3 Documentation
**Add:**
- Architecture diagram
- API documentation
- Development guide
- Troubleshooting guide

---

## Long-term Recommendations

### Architecture Evolution

1. **Plugin System** - Allow third-party agents
2. **Remote Agents** - Support networked XPC or REST APIs
3. **Multiple Projects** - Manage multiple projects simultaneously
4. **Agent Orchestration** - Complex multi-agent workflows
5. **Web Dashboard** - Browser-based UI for remote access

### Advanced Features

1. **CI/CD Integration** - GitHub Actions, GitLab CI support
2. **Docker Support** - Containerized builds and tests
3. **Code Analysis** - Static analysis, linting integration
4. **Deployment Tools** - App Store upload, beta distribution
5. **Metrics & Analytics** - Build time tracking, success rates

---

## Implementation Roadmap

### Phase 1: Stabilization (Week 1)
- ✅ Fix hardcoded paths
- ✅ Add configuration system
- ✅ Improve error handling
- ✅ Add timeout handling

### Phase 2: Feature Parity (Week 2)
- Add missing CLI commands
- Enhance dashboard with real-time updates
- Improve installation script
- Add log viewer

### Phase 3: Quality (Week 3)
- Write unit tests
- Add integration tests
- Improve documentation
- Add CI/CD pipeline

### Phase 4: Polish (Week 4)
- Structured logging
- Performance optimization
- Security hardening
- User experience improvements

---

## Conclusion

`mini.agent` has a solid foundation with clean XPC-based architecture. The immediate priorities are fixing portability issues (hardcoded paths), adding proper error handling, and implementing a configuration system. These changes will make the system production-ready for multi-user environments.

The suggested immediate implementations (Priority 1) can be completed in 1-2 days and will significantly improve reliability and usability.

---

## Appendix: Agent Details

### BuilderAgent
- **Purpose:** Execute Swift package builds
- **Dependencies:** SwiftPM
- **Key Files:** BuilderLogic.swift, SwiftPMInvoker.swift, CompileDiagnosticsParser.swift
- **Output:** Parsed build diagnostics with error/warning counts

### TestAgent  
- **Purpose:** Run test suites
- **Key Files:** TestLogic.swift, TestOutputParser.swift
- **Output:** Test results with pass/fail counts

### DebuggerAgent
- **Purpose:** Parse and analyze crash logs
- **Key Files:** DebuggerLogic.swift, CrashLogParser.swift, StacktraceFormatter.swift
- **Output:** Formatted stack traces

### RepoAgent
- **Purpose:** Git operations (commit, branch, push, pull, status)
- **Key Files:** RepoLogic.swift, GitRunner.swift
- **Output:** Git command results

### MemoryAgent
- **Purpose:** Persistent note-taking with history
- **Key Files:** MemoryLogic.swift, MemoryDiff.swift
- **Output:** Saved files + diff from last snapshot

### TerminalProxyAgent
- **Purpose:** Execute shell commands with safety filtering
- **Key Files:** TerminalProxyAgentLogic.swift, CommandFilter.swift
- **Output:** Command execution results

### SupervisorAgent
- **Purpose:** Monitor agent health, restart failed services
- **Key Files:** SupervisorAgentLogic.swift, AgentProcessChecker.swift
- **Output:** System status report

---

**End of Analysis**
