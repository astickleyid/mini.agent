import Foundation

struct BuildDiagnostic: Codable {
    let file: String
    let line: String
    let message: String
    let isError: Bool
}

class CompileDiagnosticsParser {

    func parse(_ text: String) -> [BuildDiagnostic] {

        let lines = text.split(separator: "\n")
        var out: [BuildDiagnostic] = []

        for line in lines {

            let s = String(line)

            if s.contains(": error:") || s.contains(": warning:") {

                let comps = s.split(separator: ":")
                if comps.count >= 4 {

                    let file = String(comps[0])
                    let lineNo = String(comps[1])
                    let isError = s.contains("error")

                    let msgPart = comps.dropFirst(3).joined(separator: ":")
                    let message = msgPart.trimmingCharacters(in: .whitespaces)

                    out.append(
                        BuildDiagnostic(file: file,
                                        line: lineNo,
                                        message: message,
                                        isError: isError)
                    )
                }
            }
        }

        return out
    }
}
