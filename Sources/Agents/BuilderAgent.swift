#if canImport(Foundation)
#endif
import Foundation
import MiniAgentCore

@available(iOS 13.4, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
@available(iOS 13.0.0, *)
public actor BuilderAgent: Agent {
    public let name = "builder"
    public private(set) var status: AgentStatus = .idle
    
    private let logger: Logger
    private let config: MiniConfiguration
    
    public init() {
        self.logger = Logger(agent: "builder")
        self.config = MiniConfiguration.load()
    }
    
    public func start() async throws {
        status = .running
        await logger.info("BuilderAgent started")
    }
    
    public func stop() async {
        status = .stopped
        await logger.info("BuilderAgent stopped")
    }
    
    public func handle(_ request: AgentRequest) async -> AgentResult {
        await logger.info("Handling request: \(request.action)")
        
        switch request.action {
        case "build":
            return await build()
        default:
            return .failure("Unknown action: \(request.action)")
        }
    }
    
    private func build() async -> AgentResult {
        guard FileManager.default.fileExists(atPath: config.projectPath) else {
            return .failure("Project not found at: \(config.projectPath)")
        }
        
        await logger.info("Building project at: \(config.projectPath)")
        
#if os(macOS)
        let process = Process()
        process.currentDirectoryURL = URL(fileURLWithPath: config.projectPath)
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["build"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if process.terminationStatus == 0 {
                await logger.info("Build successful")
                return .success("✅ Build completed successfully\n\n\(output)")
            } else {
                await logger.error("Build failed with status: \(process.terminationStatus)")
                return .failure("❌ Build failed\n\n\(output)")
            }
        } catch {
            await logger.error("Build error: \(error)")
            return .failure("❌ Build error: \(error.localizedDescription)")
        }
#else
        await logger.error("Build is only supported on macOS.")
        return .failure("Build is only supported on macOS.")
#endif
    }
}
