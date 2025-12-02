import Foundation
import XPCShared

class MiniClient {

    private func createConnection(serviceName: String) -> NSXPCConnection? {
        return NSXPCConnection(machServiceName: serviceName, options: [])
    }

    func send(_ type: AgentRequestType, payload: String? = nil) -> String {

        let request = AgentRequest(type: type, payload: payload)
        let serviceName = resolveService(for: type)

        guard let conn = createConnection(serviceName: serviceName) else {
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

        // Add 30 second timeout
        if sem.wait(timeout: .now() + 30) == .timedOut {
            conn.invalidate()
            return AgentError.timeout(service: serviceName).description
        }

        conn.invalidate()
        return result
    }

    private func resolveService(for type: AgentRequestType) -> String {
        switch type {
        case .build: return "mini.agent.builder"
        case .debug: return "mini.agent.debugger"
        case .memory: return "mini.agent.memory"
        case .commit, .branch, .repoStatus: return "mini.agent.repo"
        case .test: return "mini.agent.test"
        case .shell: return "mini.agent.terminalproxy"
        case .heartbeat, .restart: return "mini.agent.supervisor"
        case .logs: return "mini.agent.supervisor"
        }
    }
}
