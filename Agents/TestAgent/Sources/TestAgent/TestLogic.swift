import Foundation

class TestLogic {

    private let log = Logger(agent: "test")
    private let projectPath = "/Users/austinstickley/.mini/projects/current"

    func runTests() -> String {

        guard FileManager.default.fileExists(atPath: projectPath) else {
            return "TestAgent error: project folder not found at \(projectPath)"
        }

        log.info("Running: swift test")

        let output = shell("swift test --parallel")

        log.info("Test output captured.")

        let parsed = TestOutputParser().parse(output)

        return """
🧪 Test Report
        --------------------
        Raw Output:
        \(output)

        Parsed Summary:
        \(parsed)
        """
    }

    private func shell(_ cmd: String) -> String {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.currentDirectoryPath = projectPath
        process.arguments = ["-c", cmd]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()

        return String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    }
}
