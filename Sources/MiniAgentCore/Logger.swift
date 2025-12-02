import Foundation

@available(iOS 13.4, *)
public actor Logger {
    private let agentName: String
    private let logDirectory: URL
    
    public init(agent: String) {
        self.agentName = agent
        // Resolve an app-writable directory. Prefer Application Support on iOS/macOS.
        let baseDir: URL
        if let appSupport = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            baseDir = appSupport
        } else {
            // Fallback to documents directory if Application Support is unavailable
            baseDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        }
        self.logDirectory = baseDir
            .appendingPathComponent(".mini", isDirectory: true)
            .appendingPathComponent("logs", isDirectory: true)

        let agentLogDir = logDirectory.appendingPathComponent(agent, isDirectory: true)
        try? FileManager.default.createDirectory(at: agentLogDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func info(_ message: String) {
        write(level: "INFO", message: message)
    }
    
    public func error(_ message: String) {
        write(level: "ERROR", message: message)
    }
    
    private func write(level: String, message: String) {
        let fileURL = logDirectory
            .appendingPathComponent(agentName, isDirectory: true)
            .appendingPathComponent("runtime.log")
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let entry = "[\(timestamp)] [\(level)] \(message)\n"
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }
        
        guard let handle = try? FileHandle(forWritingTo: fileURL) else { return }
        defer { try? handle.close() }
        
        do {
            try handle.seekToEnd()
            if let data = entry.data(using: .utf8) {
                try handle.write(contentsOf: data)
            }
        } catch {
            // Ignore logging errors
        }
    }
}
