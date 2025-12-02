import Foundation
import MiniAgentCore

#if !os(iOS) && !os(macOS)
public struct Logger {
    public init(agent: String) {}
    public func info(_ message: @autoclosure () -> String) async {}
}
#else
@available(iOS 13.4, macOS 10.15.4, *)
extension Logger {
    // No changes; rely on platform Logger where available
}
#endif

@available(iOS 13.4, macOS 10.15.4, *)
public actor RepoAgent: Agent {
    public let name = "repo"
    public private(set) var status: AgentStatus = .idle
    
    private let logger: Logger
    private let config: MiniConfiguration
    
    public init() {
        self.logger = Logger(agent: "repo")
        self.config = MiniConfiguration.load()
    }
    
    public func start() async throws {
        status = .running
        await logger.info("RepoAgent started")
    }
    
    public func stop() async {
        status = .stopped
        await logger.info("RepoAgent stopped")
    }
    
    public func handle(_ request: AgentRequest) async -> AgentResult {
        await logger.info("Handling request: \(request.action)")
        
        switch request.action {
        case "commit":
            guard let message = request.parameters["message"] else {
                return .failure("Commit message required")
            }
            return await commit(message: message)
        case "status":
            return await status()
        case "branch":
            guard let name = request.parameters["name"] else {
                return .failure("Branch name required")
            }
            return await createBranch(name: name)
        default:
            return .failure("Unknown action: \(request.action)")
        }
    }
    
    private func commit(message: String) async -> AgentResult {
        await logger.info("Creating commit: \(message)")
        
        // Add all changes
        let addResult = await runGit(["add", "-A"])
        guard addResult.success else { return addResult }
        
        // Commit
        let commitResult = await runGit(["commit", "-m", message])
        if commitResult.success {
            return .success("✅ Committed: \(message)")
        } else {
            return commitResult
        }
    }
    
    private func status() async -> AgentResult {
        await logger.info("Checking git status")
        return await runGit(["status", "--short"])
    }
    
    private func createBranch(name: String) async -> AgentResult {
        await logger.info("Creating branch: \(name)")
        let result = await runGit(["checkout", "-b", name])
        if result.success {
            return .success("✅ Created branch: \(name)")
        }
        return result
    }
    
    private func runGit(_ arguments: [String]) async -> AgentResult {
#if os(macOS)
        let process = Foundation.Process()
        process.currentDirectoryURL = URL(fileURLWithPath: config.projectPath)
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        
        let pipe = Foundation.Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if process.terminationStatus == 0 {
                return .success(output.isEmpty ? "✅ Done" : output)
            } else {
                return .failure("Git error: \(output)")
            }
        } catch {
            return .failure("Git execution error: \(error.localizedDescription)")
        }
#else
        return .failure("Git execution is only supported on macOS.")
#endif
    }
}
