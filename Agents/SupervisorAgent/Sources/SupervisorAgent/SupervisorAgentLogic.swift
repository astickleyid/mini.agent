import Foundation

class SupervisorLogic {

    private let log = Logger(agent: "supervisor")
    private let checker = AgentProcessChecker()

    private let agents = [
        ("builder", "mini.agent.builder"),
        ("debugger", "mini.agent.debugger"),
        ("memory", "mini.agent.memory"),
        ("repo", "mini.agent.repo"),
        ("test", "mini.agent.test"),
        ("terminalproxy", "mini.agent.terminalproxy"),
        ("supervisor", "mini.agent.supervisor")
    ]

    private let userDir = FileManager.default.homeDirectoryForCurrentUser.path

    func heartbeat() -> String {
        return "❤️ SupervisorAgent heartbeat OK at \(Date())"
    }

    func fullStatusReport() -> String {

        var report = """
🔎 mini.agent System Status
--------------------------------
Timestamp: \(Date())

"""

        for (name, plistName) in agents {

            let running = checker.isRunning(process: name)
            let status = running ? "RUNNING" : "NOT RUNNING"

            report += "\n• \(name.capitalized) Agent: \(status)"

            if !running {
                log.error("\(name) agent offline. Attempting restart…")
                report += "\n  → Restarting..."
                report += "\n  " + restartAgent(plistName: plistName)
            }
        }

        return report + "\n--------------------------------"
    }

    func restartAgent(plistName: String) -> String {

        let plistPath = "\(userDir)/Library/LaunchAgents/\(plistName).plist"

        let unload = shell("launchctl unload \(plistPath)")
        let load = shell("launchctl load \(plistPath)")

        return """
Restart Result:
unload: \(unload)
load: \(load)
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

        return String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    }
}
