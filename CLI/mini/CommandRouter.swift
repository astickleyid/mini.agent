import Foundation
import XPCShared

class CommandRouter {

    private let client = MiniClient()

    func run() {
        let args = CommandLine.arguments.dropFirst()

        guard let cmd = args.first else {
            print(helpText())
            return
        }

        switch cmd {

        case "build":
            print(client.send(.build))

        case "test":
            print(client.send(.test))

        case "commit":
            let msg = args.dropFirst().joined(separator: " ")
            print(client.send(.commit, payload: msg))

        case "branch":
            let name = args.dropFirst().joined(separator: " ")
            print(client.send(.branch, payload: name))

        case "shell":
            let command = args.dropFirst().joined(separator: " ")
            print(client.send(.shell, payload: command))

        case "memory":
            let note = args.dropFirst().joined(separator: " ")
            print(client.send(.memory, payload: note))

        case "status":
            print(client.send(.heartbeat))

        case "logs":
            let agentName = args.dropFirst().first ?? "all"
            handleLogs(agentName)

        case "init":
            let path = args.dropFirst().first ?? FileManager.default.currentDirectoryPath
            handleInit(path)

        case "config":
            handleConfig()

        case "restart":
            let agentName = args.dropFirst().first ?? ""
            if agentName.isEmpty {
                print("Usage: mini restart <agent-name>")
            } else {
                print(client.send(.restart, payload: agentName))
            }

        case "--version", "-v":
            print("mini.agent v1.0.0")

        case "--help", "-h", "help":
            print(helpText())

        default:
            print("Unknown command: \(cmd)")
            print(helpText())
        }
    }

    private func handleLogs(_ agentName: String) {
        let logsPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/logs")
            .path

        if agentName == "all" {
            print("📋 Available agent logs:")
            if let agents = try? FileManager.default.contentsOfDirectory(atPath: logsPath) {
                for agent in agents {
                    print("  • \(agent)")
                }
            }
            print("\nUse 'mini logs <agent-name>' to view specific logs")
        } else {
            let logFile = "\(logsPath)/\(agentName)/runtime.log"
            if FileManager.default.fileExists(atPath: logFile) {
                if let content = try? String(contentsOfFile: logFile) {
                    print(content)
                } else {
                    print("❌ Could not read log file: \(logFile)")
                }
            } else {
                print("❌ Log file not found: \(logFile)")
            }
        }
    }

    private func handleInit(_ path: String) {
        let config = MiniConfiguration.default
        let projectPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/projects/current")
            .path

        do {
            // Create symlink to project
            try? FileManager.default.removeItem(atPath: projectPath)
            try FileManager.default.createSymbolicLink(
                atPath: projectPath,
                withDestinationPath: path
            )

            // Save configuration
            try config.save()

            print("""
            ✅ Project initialized successfully!
            
            Project path: \(path)
            Configuration saved to: ~/.mini/config.json
            
            You can now use:
              mini build
              mini test
              mini commit "message"
            """)
        } catch {
            print("❌ Failed to initialize: \(error.localizedDescription)")
        }
    }

    private func handleConfig() {
        let config = MiniConfiguration.load()
        print("""
        📝 mini.agent Configuration
        ---------------------------
        Project Path:  \(config.projectPath)
        Logs Path:     \(config.logsPath)
        Memory Path:   \(config.memoryPath)
        Agents Path:   \(config.agentsPath)
        
        Edit ~/.mini/config.json to change settings.
        """)
    }

    private func helpText() -> String {
        return """
        mini — available commands:
        --------------------------
        mini build                  Build the current project
        mini test                   Run tests
        mini commit "message"       Create a git commit
        mini branch "name"          Create a new git branch
        mini shell "command"        Execute a shell command
        mini memory "note"          Save a memory note
        mini status                 Check system status
        mini logs [agent]           View agent logs
        mini init [path]            Initialize project
        mini config                 Show configuration
        mini restart <agent>        Restart an agent
        mini --version, -v          Show version
        mini --help, -h             Show this help
        """
    }
}
