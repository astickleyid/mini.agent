import Foundation
import XPCShared

class TerminalProxyAgentService: NSObject {

    private let log = Logger(agent: "terminalproxy")

    func start() {
        log.info("TerminalProxyAgent started.")
        let listener = NSXPCListener.service()
        listener.delegate = self
        listener.resume()
    }
}

extension TerminalProxyAgentService: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        connection.exportedInterface =
            NSXPCInterface(with: AgentXPCProtocol.self)

        connection.exportedObject = self
        connection.resume()
        return true
    }
}

extension TerminalProxyAgentService: AgentXPCProtocol {

    func handle(_ request: AgentRequest,
                with reply: @escaping (AgentResponse) -> Void) {

        guard let payload = request.payload else {
            reply(.error("TerminalProxyAgent received empty payload"))
            return
        }

        log.info("Received terminal command: \(payload)")

        let logic = TerminalProxyLogic()
        let output = logic.execute(command: payload)

        reply(.success(output))
    }
}
