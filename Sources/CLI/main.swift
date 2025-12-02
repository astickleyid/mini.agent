import Foundation
import MiniAgentCore
import Agents

@main
struct MiniCLI {
    static func main() async {
        let args = CommandLine.arguments.dropFirst()
        
        guard let command = args.first else {
            printHelp()
            return
        }
        
        // Initialize agents
        let manager = AgentManager.shared
        await manager.registerAgent(BuilderAgent(), named: "builder")
        await manager.registerAgent(TestAgent(), named: "test")
        await manager.registerAgent(RepoAgent(), named: "repo")
        await manager.registerAgent(MemoryAgent(), named: "memory")
        await manager.registerAgent(GeneratorAgent(), named: "generator")
        
        do {
            try await manager.startAll()
            
            let result = await executeCommand(command, args: Array(args.dropFirst()), manager: manager)
            print(result)
            
            await manager.stopAll()
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
    
    static func executeCommand(_ command: String, args: [String], manager: AgentManager) async -> String {
        switch command {
        case "build":
            let request = AgentRequest(action: "build")
            let result = await manager.sendRequest(to: "builder", request: request)
            return result.success ? result.output : (result.error ?? "Build failed")
            
        case "test":
            let request = AgentRequest(action: "test")
            let result = await manager.sendRequest(to: "test", request: request)
            return result.success ? result.output : (result.error ?? "Tests failed")
            
        case "commit":
            guard let message = args.first else {
                return "❌ Usage: mini commit \"message\""
            }
            let request = AgentRequest(action: "commit", parameters: ["message": message])
            let result = await manager.sendRequest(to: "repo", request: request)
            return result.success ? result.output : (result.error ?? "Commit failed")
            
        case "branch":
            guard let name = args.first else {
                return "❌ Usage: mini branch \"name\""
            }
            let request = AgentRequest(action: "branch", parameters: ["name": name])
            let result = await manager.sendRequest(to: "repo", request: request)
            return result.success ? result.output : (result.error ?? "Branch creation failed")
            
        case "status":
            let request = AgentRequest(action: "status")
            let result = await manager.sendRequest(to: "repo", request: request)
            return result.success ? result.output : (result.error ?? "Status check failed")
            
        case "memory":
            guard let note = args.first else {
                return "❌ Usage: mini memory \"note\""
            }
            let request = AgentRequest(action: "save", parameters: ["note": note])
            let result = await manager.sendRequest(to: "memory", request: request)
            return result.success ? result.output : (result.error ?? "Memory save failed")
            
        case "generate", "gen", "add", "make", "create":
            // Join all args as the spec
            let spec = args.joined(separator: " ")
            guard !spec.isEmpty else {
                return "❌ Usage: mini generate \"your specification\"\n   Example: mini generate \"user auth with login screen\""
            }
            let request = AgentRequest(action: "generate", parameters: ["spec": spec])
            let result = await manager.sendRequest(to: "generator", request: request)
            return result.success ? result.output : (result.error ?? "Generation failed")
            
        case "init":
            let projectPath = args.first ?? FileManager.default.currentDirectoryPath
            let symlinkPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".mini/projects/current")
                .path
            
            do {
                // Remove existing symlink if it exists
                if FileManager.default.fileExists(atPath: symlinkPath) {
                    try FileManager.default.removeItem(atPath: symlinkPath)
                }
                
                // Create new symlink
                try FileManager.default.createSymbolicLink(
                    atPath: symlinkPath,
                    withDestinationPath: projectPath
                )
                
                return """
                ✅ Project initialized!
                
                Current project: \(projectPath)
                Symlink created: \(symlinkPath) → \(projectPath)
                
                Try: mini status
                """
            } catch {
                return "❌ Failed to initialize project: \(error.localizedDescription)"
            }
            
        case "config":
            let config = MiniConfiguration.load()
            return """
            📝 mini.agent Configuration
            ---------------------------
            Project Path:  \(config.projectPath)
            Logs Path:     \(config.logsPath)
            Memory Path:   \(config.memoryPath)
            """
            
        case "--version", "-v":
            return "mini.agent v2.0.0 (simplified architecture)"
            
        case "--help", "-h", "help":
            return helpText()
            
        default:
            return "❌ Unknown command: \(command)\n\n\(helpText())"
        }
    }
    
    static func printHelp() {
        print(helpText())
    }
    
    static func helpText() -> String {
        """
        mini — Simplified Agent System
        ──────────────────────────────
        mini build                  Build the current project
        mini test                   Run tests
        mini commit "message"       Create a git commit
        mini branch "name"          Create a new git branch
        mini status                 Show git status
        mini memory "note"          Save a memory note
        mini generate "spec"        Generate code from description
        mini init [path]            Initialize project (default: current dir)
        mini config                 Show configuration
        mini --version, -v          Show version
        mini --help, -h             Show this help
        
        Code Generation Examples:
          mini generate "user auth with login screen"
          mini add "todo list with add/delete"
          mini make "api client for posts"
        """
    }
}
