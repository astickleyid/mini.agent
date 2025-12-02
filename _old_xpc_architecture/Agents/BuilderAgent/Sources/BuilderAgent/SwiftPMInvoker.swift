import Foundation

class SwiftPMInvoker {

    func build(path: String) -> String {

        let process = Process()
        process.launchPath = "/bin/bash"
        process.currentDirectoryPath = path
        process.arguments = ["-c", "swift build --indicator --build-tests"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()

        return String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(),
                      as: UTF8.self)
    }
}
