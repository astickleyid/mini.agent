import Foundation

@objc public class AgentResponse: NSObject, NSSecureCoding, Codable {
    public static var supportsSecureCoding: Bool { true }

    public let output: String?
    public let error: String?

    public init(output: String?, error: String?) {
        self.output = output
        self.error = error
    }

    public static func success(_ text: String) -> AgentResponse {
        AgentResponse(output: text, error: nil)
    }

    public static func error(_ text: String) -> AgentResponse {
        AgentResponse(output: nil, error: text)
    }

    // MARK: NSSecureCoding
    public func encode(with coder: NSCoder) {
        coder.encode(output, forKey: "output")
        coder.encode(error, forKey: "error")
    }

    public required convenience init?(coder: NSCoder) {
        let o = coder.decodeObject(forKey: "output") as? String
        let e = coder.decodeObject(forKey: "error") as? String
        self.init(output: o, error: e)
    }
}
