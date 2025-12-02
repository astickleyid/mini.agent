import Foundation
import XPCShared

class TestAgentService: NSObject {

    private let log = Logger(agent: "test")

    func start() {
        log.info("TestAgent started.")
        let listener = NSXPCListener.service()
        listener.delegate = self
        listener.resume()
    }
}

extension TestAgentService: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        connection.exportedInterface =
            NSXPCInterface(with: AgentXPCProtocol.self)

        connection.exportedObject = self
        connection.resume()
        return true
    }
}

extension TestAgentService: AgentXPCProtocol {

    func handle(_ request: AgentRequest,
                with reply: @escaping (AgentResponse) -> Void) {

        log.info("Received test request.")

        let logic = TestLogic()
        let result = logic.runTests()

        reply(.success(result))
    }
}
