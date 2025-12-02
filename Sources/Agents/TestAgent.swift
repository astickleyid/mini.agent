import Foundation
import MiniAgentCore

@available(iOS 13.4, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public actor TestAgent: Agent {
    public let name = "test"
    public private(set) var status: AgentStatus = .idle
    
    private let logger: Logger
    private let config: MiniConfiguration
    
    public init() {
        self.logger = Logger(agent: "test")
        self.config = MiniConfiguration.load()
    }
    
    public func start() async throws {
        status = .running
        await logger.info("TestAgent started")
    }
    
    public func stop() async {
        status = .stopped
        await logger.info("TestAgent stopped")
    }
    
    public func handle(_ request: AgentRequest) async -> AgentResult {
        await logger.info("Handling request: \(request.action)")
        
        switch request.action {
        case "test":
            return await runTests()
        default:
            return .failure("Unknown action: \(request.action)")
        }
    }
    
    private func runTests() async -> AgentResult {
        #if os(macOS)
        guard FileManager.default.fileExists(atPath: config.projectPath) else {
            return .failure("Project not found at: \(config.projectPath)")
        }
        
        await logger.info("Running tests at: \(config.projectPath)")
        
        let process = Process()
        process.currentDirectoryURL = URL(fileURLWithPath: config.projectPath)
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["test"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if process.terminationStatus == 0 {
                await logger.info("Tests passed")
                return .success("✅ All tests passed\n\n\(output)")
            } else {
                await logger.error("Tests failed with status: \(process.terminationStatus)")
                return .failure("❌ Tests failed\n\n\(output)")
            }
        } catch {
            await logger.error("Test error: \(error)")
            return .failure("❌ Test error: \(error.localizedDescription)")
        }
        #else
        await logger.error("Running tests via Process is not supported on this platform")
        return .failure("Running tests is only supported on macOS.")
        #endif
    }
}
