import Foundation

class TestOutputParser {

    struct Result: Codable {
        let total: Int
        let passed: Int
        let failed: Int
        let failures: [String]
        let executionTime: String
    }

    func parse(_ output: String) -> String {

        var total = 0
        var passed = 0
        var failed = 0
        var failures: [String] = []
        var time = "N/A"

        let lines = output.split(separator: "\n")

        for line in lines {

            let str = String(line)

            if str.contains("Executed") && str.contains("tests") {
                let comps = str.split(separator: " ")

                if comps.count >= 7 {
                    total = Int(comps[1]) ?? 0
                    failed = Int(comps[5]) ?? 0
                    time = "\(comps[7]) seconds"
                }
            }

            if str.contains(": error:") {
                failures.append(str)
            }
        }

        passed = total - failed

        let result = Result(total: total,
                            passed: passed,
                            failed: failed,
                            failures: failures,
                            executionTime: time)

        if let data = try? JSONEncoder().encode(result),
           let json = String(data: data, encoding: .utf8) {
            return json
        }

        return "Unable to parse test output."
    }
}
