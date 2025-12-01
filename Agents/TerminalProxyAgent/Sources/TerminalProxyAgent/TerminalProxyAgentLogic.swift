import Foundation

class TerminalProxyLogic {

    private let log = Logger(agent: "terminalproxy")
    private let filter = CommandFilter()

    func execute(command: String) -> String {

        if !filter.isAllowed(command) {
            log.error("Blocked unsafe command: \(command)")
            return "❌ TerminalProxy: Command not allowed.\n"
        }

        let start = Date().timeIntervalSince1970
        log.info("Executing: \(command)")

        let result = shell(command)

        let end = Date().timeIntervalSince1970
        let duration = String(format: "%.3f", end - start)

        log.info("Command finished in \(duration)s")

        return """
🖥️ Terminal Output
-------------------------
Command: \(command)
Duration: \(duration)s

Output:
\(result)
"""
    }

    private func shell(_ cmd: String) -> String {

        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", cmd]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: data, as: UTF8.self)
    }
}
