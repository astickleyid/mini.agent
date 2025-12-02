import Foundation

@objc public enum AgentRequestType: Int, Codable {
    case build
    case debug
    case memory
    case commit
    case branch
    case test
    case shell
    case heartbeat
    case logs
    case restart
    case repoStatus
}

@objc public class AgentRequest: NSObject, NSSecureCoding, Codable {
    public static var supportsSecureCoding: Bool { true }

    public let type: AgentRequestType
    public let payload: String?

    public init(type: AgentRequestType, payload: String?) {
        self.type = type
        self.payload = payload
    }

    // MARK: NSSecureCoding
    public func encode(with coder: NSCoder) {
        coder.encode(type.rawValue, forKey: "type")
        coder.encode(payload, forKey: "payload")
    }

    public required convenience init?(coder: NSCoder) {
        let raw = coder.decodeInteger(forKey: "type")
        guard let t = AgentRequestType(rawValue: raw) else { return nil }
        let p = coder.decodeObject(forKey: "payload") as? String
        self.init(type: t, payload: p)
    }
}
