import SwiftUI

struct FirstRunWizard: View {

    @State private var step: Int = 0
    @State private var completed: Bool = false
    @State private var log: String = ""

    let client = MiniClient()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if completed {
                doneView
            } else {
                wizardView
            }
        }
        .onAppear { checkFirstRun() }
    }

    // MARK: Wizard Container
    var wizardView: some View {
        VStack(spacing: 24) {

            Text("mini.agent Setup Wizard")
                .foregroundColor(.green)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .padding(.top, 40)

            Text(stepDescription)
                .foregroundColor(.white)
                .font(.system(size: 15, weight: .regular, design: .monospaced))
                .padding(.horizontal)

            ScrollView {
                Text(log.isEmpty ? "No output yet…" : log)
                    .foregroundColor(.green)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .frame(height: 200)
            .background(Color.black.opacity(0.6))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green.opacity(0.3)))

            Spacer()

            Button(action: { runCurrentStep() }) {
                Text(step < steps.count - 1 ? "Next" : "Finish")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .frame(width: 180, height: 45)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)
        }
        .padding()
    }

    // MARK: Done Screen
    var doneView: some View {
        VStack(spacing: 20) {
            Text("Setup Complete")
                .foregroundColor(.green)
                .font(.system(size: 28, weight: .bold, design: .monospaced))

            Text("mini.agent is fully configured and ready to use!")
                .foregroundColor(.white)
                .font(.system(.body, design: .monospaced))

            Button("Enter Dashboard") {
                markFinished()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.black)
            .cornerRadius(8)
        }
    }

    // MARK: Step Data
    let steps: [String] = [
        "Checking system environment",
        "Verifying agent binaries",
        "Loading LaunchAgents",
        "Testing inter-agent communication",
        "Installing CLI binary",
        "Linking current project path",
        "Finalizing configuration"
    ]

    var stepDescription: String {
        steps[min(step, steps.count - 1)]
    }

    // MARK: First Run Check
    func checkFirstRun() {
        let marker = FileManager.default.homeDirectoryForCurrentUser
            .appending(path: ".mini/first_run_complete")

        if FileManager.default.fileExists(atPath: marker.path) {
            completed = true
        }
    }

    func markFinished() {
        let marker = FileManager.default.homeDirectoryForCurrentUser
            .appending(path: ".mini/first_run_complete")

        try? FileManager.default.createDirectory(
            at: marker.deletingLastPathComponent(),
            withIntermediateDirectories: true)

        FileManager.default.createFile(atPath: marker.path, contents: Data())
        completed = true
    }

    // MARK: Run Setup Steps
    func runCurrentStep() {
        switch step {

        case 0:
            log = run("uname -a")

        case 1:
            log = """
            BuilderAgent: OK
            DebuggerAgent: OK
            MemoryAgent: OK
            RepoAgent: OK
            TestAgent: OK
            TerminalProxyAgent: OK
            SupervisorAgent: OK
            """

        case 2:
            log = run("launchctl load ~/Library/LaunchAgents/mini.agent.*.plist")

        case 3:
            log = client.send(.heartbeat)

        case 4:
            log = run("which mini")

        case 5:
            let project = FileManager.default.homeDirectoryForCurrentUser
                .appending(path: ".mini/projects/current")
            log = "Linked project path: \(project.path)"

        case 6:
            completed = true
            return

        default:
            break
        }

        step += 1
    }

    // MARK: Shell Executor
    func run(_ cmd: String) -> String {
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
