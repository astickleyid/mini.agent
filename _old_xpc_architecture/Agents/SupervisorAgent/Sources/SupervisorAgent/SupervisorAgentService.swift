import Foundation
import XPCShared

class SupervisorAgentService: NSObject {

    private let log = Logger(agent: "supervisor")

    func start() {
        log.info("SupervisorAgent started.")
        let listener = NSXPCListener.service()
        listener.delegate = self
        listener.resume()
    }
}

extension SupervisorAgentService: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        connection.exportedInterface =
            NSXPCInterface(with: AgentXPCProtocol.self)

        connection.exportedObject = self
        connection.resume()
        return true
    }
}

extension SupervisorAgentService: AgentXPCProtocol {

    func handle(_ request: AgentRequest,
                with reply: @escaping (AgentResponse) -> Void) {

        let logic = SupervisorLogic()

        switch request.type {

        case .heartbeat:
            reply(.success(logic.heartbeat()))

        case .restart:
            if let agentName = request.payload {
                let plistName = "mini.agent.\(agentName)"
                reply(.success(logic.restartAgent(plistName: plistName)))
            } else {
                reply(.error("No agent name provided"))
            }

        default:
            reply(.success(logic.fullStatusReport()))
        }
    }
}
