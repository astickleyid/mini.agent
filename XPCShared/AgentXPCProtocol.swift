import Foundation

@objc public protocol AgentXPCProtocol {
    func handle(_ request: AgentRequest, with reply: @escaping (AgentResponse) -> Void)
}
