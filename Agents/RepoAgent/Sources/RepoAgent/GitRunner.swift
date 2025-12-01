import Foundation

class GitRunner {

    func run(_ cmd: String, at path: String) -> String {

        let process = Process()
        process.launchPath = "/bin/bash"
        process.currentDirectoryPath = path
        process.arguments = ["-c", cmd]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: data, as: UTF8.self)
    }
}
