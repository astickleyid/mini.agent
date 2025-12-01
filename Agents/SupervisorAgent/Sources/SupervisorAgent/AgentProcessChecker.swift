import Foundation

class AgentProcessChecker {

    func isRunning(process: String) -> Bool {

        let task = Process()
        let pipe = Pipe()

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "ps -ax | grep \(process) | grep -v grep"]
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return !String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespaces).isEmpty
    }
}
