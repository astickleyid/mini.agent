import Foundation

/// Base protocol for all agents
@available(iOS 13.0, *)
public protocol Agent: Actor {
    var name: String { get }
    var status: AgentStatus { get }
    
    func start() async throws
    func stop() async
    func handle(_ request: AgentRequest) async -> AgentResult
}

/// Agent status
public enum AgentStatus: String, Codable, Sendable {
    case idle
    case running
    case stopped
    case error
}

/// Generic agent request
public struct AgentRequest: Codable, Sendable {
    public let action: String
    public let parameters: [String: String]
    
    public init(action: String, parameters: [String: String] = [:]) {
        self.action = action
        self.parameters = parameters
    }
}

/// Generic agent result
public struct AgentResult: Codable, Sendable {
    public let success: Bool
    public let output: String
    public let error: String?
    
    public init(success: Bool, output: String, error: String? = nil) {
        self.success = success
        self.output = output
        self.error = error
    }
    
    public static func success(_ output: String) -> AgentResult {
        AgentResult(success: true, output: output)
    }
    
    public static func failure(_ error: String) -> AgentResult {
        AgentResult(success: false, output: "", error: error)
    }
}
