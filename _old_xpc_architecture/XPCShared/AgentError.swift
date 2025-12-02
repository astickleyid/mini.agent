import Foundation

public enum AgentError: Error, CustomStringConvertible {
    case connectionFailed(service: String)
    case timeout(service: String)
    case invalidResponse
    case projectNotFound(path: String)
    case operationFailed(reason: String)
    
    public var description: String {
        switch self {
        case .connectionFailed(let service):
            return "❌ Failed to connect to \(service). Is the agent running? Try 'mini status' to check."
        case .timeout(let service):
            return "⏱️  Timeout waiting for \(service). The operation took too long."
        case .invalidResponse:
            return "❌ Received invalid response from agent."
        case .projectNotFound(let path):
            return "📁 Project not found at: \(path)\nRun 'mini init' to set up a project."
        case .operationFailed(let reason):
            return "❌ Operation failed: \(reason)"
        }
    }
}
