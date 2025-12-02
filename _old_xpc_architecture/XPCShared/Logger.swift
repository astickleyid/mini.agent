import Foundation

/// Simple file-based logger that writes to `~/.mini/logs/<agent>/runtime.log`.
public final class Logger {
    private let agent: String
    private let logDirectory: String

    public init(agent: String) {
        self.agent = agent
        self.logDirectory = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/logs")
            .path
        try? FileManager.default.createDirectory(
            atPath: "\(logDirectory)/\(agent)",
            withIntermediateDirectories: true
        )
    }

    private func write(level: String, message: String) {
        let path = "\(logDirectory)/\(agent)/runtime.log"
        let entry = "[\(Date())] [\(level)] \(message)\n"

        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil)
        }

        guard let handle = FileHandle(forWritingAtPath: path) else { return }
        defer { try? handle.close() }

        do {
            try handle.seekToEnd()
            if let data = entry.data(using: .utf8) {
                try handle.write(contentsOf: data)
            }
        } catch {
            // Swallow logging errors to avoid crashing callers.
        }
    }

    public func info(_ message: String) {
        write(level: "INFO", message: message)
    }

    public func error(_ message: String) {
        write(level: "ERROR", message: message)
    }
}
