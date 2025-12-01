import Foundation
import XPCShared

class BuilderAgentService: NSObject {

    private let log = Logger(agent: "builder")

    func start() {
        log.info("BuilderAgent started.")
        let listener = NSXPCListener.service()
        listener.delegate = self
        listener.resume()
    }
}

extension BuilderAgentService: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        connection.exportedInterface = NSXPCInterface(with: AgentXPCProtocol.self)
        connection.exportedObject = self
        connection.resume()
        return true
    }
}

extension BuilderAgentService: AgentXPCProtocol {

    func handle(_ request: AgentRequest, with reply: @escaping (AgentResponse) -> Void) {

        guard request.type == .build else {
            reply(.error("BuilderAgent only supports .build"))
            return
        }

        let logic = BuilderLogic()
        let result = logic.build()
        reply(.success(result))
    }
}
