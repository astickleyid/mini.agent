import Foundation
#if canImport(os)
import os
#endif
import MiniAgentCore

// Unified logger abstraction that uses os.Logger when available, otherwise prints.
struct AgentLogger {
    let agent: String

    // Public, synchronous API callable on all OSes
    func info(_ message: String) {
        if #available(iOS 14.0, *), _supportsOSLogger {
            _osInfo("\(message)")
        } else {
            print("[INFO][\(agent)] \(message)")
        }
    }

    func error(_ message: String) {
        if #available(iOS 14.0, *), _supportsOSLogger {
            _osError("\(message)")
        } else {
            print("[ERROR][\(agent)] \(message)")
        }
    }

    // MARK: - Private helpers
#if canImport(os)
    @available(iOS 14.0, *)
    private var osLogger: os.Logger { os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "app", category: agent) }

    @available(iOS 14.0, *)
    private func _osInfo(_ message: String) {
        osLogger.info("\(message)")
    }

    @available(iOS 14.0, *)
    private func _osError(_ message: String) {
        osLogger.error("\(message)")
    }

    private var _supportsOSLogger: Bool { true }
#else
    private func _osInfo(_ message: String) {}
    private func _osError(_ message: String) {}
    private var _supportsOSLogger: Bool { false }
#endif
}

@available(iOS 13.0.0, *)
public actor MemoryAgent: Agent {
    public let name = "memory"
    public private(set) var status: AgentStatus = .idle
    
    private let logger: AgentLogger
    private let config: MiniConfiguration
    
    public init() {
        self.logger = AgentLogger(agent: "memory")
        self.config = MiniConfiguration.load()
    }
    
    public func start() async throws {
        status = .running
        logger.info("MemoryAgent started")
        
        // Ensure memory directories exist
        try? FileManager.default.createDirectory(
            atPath: config.memoryPath,
            withIntermediateDirectories: true
        )
    }
    
    public func stop() async {
        status = .stopped
        logger.info("MemoryAgent stopped")
    }
    
    public func handle(_ request: AgentRequest) async -> AgentResult {
        logger.info("Handling request: \(request.action)")
        
        switch request.action {
        case "save":
            guard let note = request.parameters["note"] else {
                return .failure("Note content required")
            }
            return await saveNote(note)
        case "list":
            return await listNotes()
        default:
            return .failure("Unknown action: \(request.action)")
        }
    }
    
    private func saveNote(_ note: String) async -> AgentResult {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        
        let filename = "\(timestamp).md"
        let filepath = "\(config.memoryPath)/\(filename)"
        
        let content = """
        # Memory Note
        **Date:** \(Date())
        
        \(note)
        """
        
        do {
            try content.write(toFile: filepath, atomically: true, encoding: .utf8)
            logger.info("Saved note: \(filename)")
            return .success("✅ Note saved: \(filename)")
        } catch {
            logger.error("Failed to save note: \(error)")
            return .failure("Failed to save note: \(error.localizedDescription)")
        }
    }
    
    private func listNotes() async -> AgentResult {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: config.memoryPath)
            let notes = files.filter { $0.hasSuffix(".md") }.sorted().reversed()
            
            if notes.isEmpty {
                return .success("No notes found")
            }
            
            let output = "📝 Memory Notes:\n" + notes.map { "  • \($0)" }.joined(separator: "\n")
            return .success(output)
        } catch {
            return .failure("Failed to list notes: \(error.localizedDescription)")
        }
    }
    
}
