import Foundation

class StacktraceFormatter {

    func format(_ text: String) -> String {

        let lines = text.split(separator: "\n")

        var out = ""
        for line in lines {
            let s = String(line).trimmingCharacters(in: .whitespaces)

            if s.contains("0x") && s.contains("_swift") {
                out += "  → \(s)\n"
            }
        }

        if out.isEmpty { out = "No Swift frames detected." }
        return out
    }
}
