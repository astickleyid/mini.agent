import Foundation

class MemoryDiff {

    func compareLatest(basePath: String) -> String {

        let historyDir = "\(basePath)/history"

        guard let files = try? FileManager.default.contentsOfDirectory(
            atPath: historyDir)
            .sorted() else {
            return "No previous snapshots."
        }

        guard files.count >= 2 else {
            return "Not enough snapshots to diff."
        }

        let last = files[files.count - 1]
        let prev = files[files.count - 2]

        let lastData = try? Data(contentsOf: URL(
            fileURLWithPath: "\(historyDir)/\(last)"
        ))
        let prevData = try? Data(contentsOf: URL(
            fileURLWithPath: "\(historyDir)/\(prev)"
        ))

        guard let ld = lastData, let pd = prevData,
              let lastObj = try? sharedJSONDecoder.decode(MemorySnapshot.self, from: ld),
              let prevObj = try? sharedJSONDecoder.decode(MemorySnapshot.self, from: pd)
        else {
            return "Unable to decode memory snapshots."
        }

        return self.diff(prevObj.content, lastObj.content)
    }

    func diff(_ old: String, _ new: String) -> String {

        let oldLines = old.split(separator: "\n")
        let newLines = new.split(separator: "\n")

        var result = ""

        for line in newLines {
            if !oldLines.contains(line) {
                result += "+ \(line)\n"
            }
        }

        for line in oldLines {
            if !newLines.contains(line) {
                result += "- \(line)\n"
            }
        }

        if result.isEmpty {
            result = "No meaningful changes."
        }

        return result
    }
}
