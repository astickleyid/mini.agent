import Foundation
import XPCShared

class MemoryAgentService: NSObject {

    private let log = Logger(agent: "memory")

    func start() {
        log.info("MemoryAgent started.")
        let listener = NSXPCListener.service()
        listener.delegate = self
        listener.resume()
    }
}

extension MemoryAgentService: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        connection.exportedInterface =
            NSXPCInterface(with: AgentXPCProtocol.self)

        connection.exportedObject = self
        connection.resume()
        return true
    }
}

extension MemoryAgentService: AgentXPCProtocol {

    func handle(_ request: AgentRequest, with reply: @escaping (AgentResponse) -> Void) {

        log.info("Received memory request")

        guard let payload = request.payload else {
            reply(.error("MemoryAgent received no payload"))
            return
        }

        let result = MemoryLogic().recordMemory(payload)
        reply(.success(result))
    }
}
