import Foundation
import XPCShared

class DebuggerAgentService: NSObject {

    private let log = Logger(agent: "debugger")

    func start() {
        log.info("DebuggerAgent started.")
        let listener = NSXPCListener.service()
        listener.delegate = self
        listener.resume()
    }
}

extension DebuggerAgentService: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        connection.exportedInterface =
            NSXPCInterface(with: AgentXPCProtocol.self)

        connection.exportedObject = self
        connection.resume()
        return true
    }
}

extension DebuggerAgentService: AgentXPCProtocol {

    func handle(_ request: AgentRequest,
                with reply: @escaping (AgentResponse) -> Void) {

        guard let payload = request.payload else {
            reply(.error("DebuggerAgent received empty payload"))
            return
        }

        let result = DebuggerLogic().analyzeCrashLog(payload)
        reply(.success(result))
    }
}
