import Foundation

struct CrashSummary {
    let summary: String
    let signal: String
}

class CrashLogParser {

    func parse(_ crash: String) -> CrashSummary {

        var summary = "Unknown"
        var signal = "Unknown"

        for line in crash.split(separator: "\n") {
            let s = String(line)

            if s.starts(with: "Exception Type:") {
                summary = s.replacingOccurrences(of: "Exception Type:", with: "").trimmingCharacters(in: .whitespaces)
            }

            if s.starts(with: "Exception Codes:") {
                signal = s.replacingOccurrences(of: "Exception Codes:", with: "").trimmingCharacters(in: .whitespaces)
            }
        }

        return CrashSummary(summary: summary, signal: signal)
    }
}
