import Foundation

class MemoryLogic {

    private let log = Logger(agent: "memory")
    private let basePath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".mini/memory").path

    func recordMemory(_ text: String) -> String {

        let dateString = Self.dateStamp()
        let summaryDir = "\(basePath)/summaries"
        let filePath = "\(summaryDir)/\(dateString).md"

        try? FileManager.default.createDirectory(
            atPath: summaryDir, withIntermediateDirectories: true)

        let entry = """
## Memory Entry — \(dateString)
\(text)

----------------------------

"""

        append(to: filePath, content: entry)
        log.info("Saved memory entry: \(filePath)")

        let historyPath = "\(basePath)/history/\(dateString).json"
        try? FileManager.default.createDirectory(
            atPath: "\(basePath)/history",
            withIntermediateDirectories: true)

        let metadata = MemorySnapshot(
            timestamp: Date().timeIntervalSince1970,
            content: text
        )

        if let json = try? sharedJSONEncoder.encode(metadata) {
            FileManager.default.createFile(atPath: historyPath,
                                           contents: json)
        }

        let diff = MemoryDiff().compareLatest(basePath: basePath)

        return """
Memory saved successfully.
Summary File: \(filePath)
History File: \(historyPath)

Diff vs last snapshot:
\(diff)
"""
    }

    private func append(to file: String, content: String) {
        if FileManager.default.fileExists(atPath: file) == false {
            FileManager.default.createFile(atPath: file,
                                           contents: nil,
                                           attributes: nil)
        }

        if let handle = FileHandle(forWritingAtPath: file) {
            handle.seekToEndOfFile()
            handle.write(content.data(using: .utf8)!)
            handle.closeFile()
        }
    }

    static func dateStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return f.string(from: Date())
    }
}

struct MemorySnapshot: Codable {
    let timestamp: Double
    let content: String
}
