import Foundation

class BuilderLogic {

    private let log = Logger(agent: "builder")
    private let spm = SwiftPMInvoker()
    private let reporter = BuildReporter()

    private let projectPath: String

    init() {
        self.projectPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/projects/current")
            .path
    }

    func build() -> String {

        guard FileManager.default.fileExists(atPath: projectPath) else {
            return "BuilderAgent error: project folder not found at \(projectPath)"
        }

        log.info("Running swift build...")

        let output = spm.build(path: projectPath)

        let parsed = CompileDiagnosticsParser().parse(output)

        return reporter.render(buildOutput: output, diagnostics: parsed)
    }
}
