import Foundation

/// Manages all agents in the system
@available(iOS 13.0, *)
@MainActor
public class AgentManager: ObservableObject {
    @Published public private(set) var agents: [String: any Agent] = [:]
    @Published public private(set) var isRunning = false
    
    public static let shared = AgentManager()
    
    private init() {}
    
    public func registerAgent(_ agent: any Agent, named name: String) {
        agents[name] = agent
    }
    
    public func startAll() async throws {
        isRunning = true
        for agent in agents.values {
            try await agent.start()
        }
    }
    
    public func stopAll() async {
        for agent in agents.values {
            await agent.stop()
        }
        isRunning = false
    }
    
    public func sendRequest(to agentName: String, request: AgentRequest) async -> AgentResult {
        guard let agent = agents[agentName] else {
            return .failure("Agent '\(agentName)' not found")
        }
        return await agent.handle(request)
    }
    
    public func getAgentStatus(for agentName: String) async -> AgentStatus? {
        guard let agent = agents[agentName] else { return nil }
        return await agent.status
    }
}
