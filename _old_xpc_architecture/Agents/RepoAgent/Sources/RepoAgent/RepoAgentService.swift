import Foundation
import XPCShared

class RepoAgentService: NSObject {

    private let log = Logger(agent: "repo")

    func start() {
        log.info("RepoAgent started.")
        let listener = NSXPCListener.service()
        listener.delegate = self
        listener.resume()
    }
}

extension RepoAgentService: NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {

        connection.exportedInterface =
            NSXPCInterface(with: AgentXPCProtocol.self)

        connection.exportedObject = self
        connection.resume()
        return true
    }
}

extension RepoAgentService: AgentXPCProtocol {

    func handle(_ request: AgentRequest, with reply: @escaping (AgentResponse) -> Void) {

        guard let payload = request.payload else {
            reply(.error("RepoAgent received empty payload"))
            return
        }

        log.info("Repo request: \(request.type.rawValue), payload: \(payload)")

        let logic = RepoLogic()

        switch request.type {

        case .commit:
            reply(.success(logic.commit(message: payload)))

        case .branch:
            reply(.success(logic.branch(name: payload)))

        default:
            reply(.error("Unsupported repo request"))
        }
    }
}
