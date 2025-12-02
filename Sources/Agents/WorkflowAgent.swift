import Foundation
import MiniAgentCore

/// Agent for managing daily workflow and task tracking
public actor WorkflowAgent: Agent {
    public let name = "workflow"
    public private(set) var status: AgentStatus = .idle
    
    private let logger: Logger
    private let config: MiniConfiguration
    private var currentSession: WorkSession?
    
    public init() {
        self.logger = Logger(agent: "workflow")
        self.config = MiniConfiguration.load()
        Task {
            await loadSession()
        }
    }
    
    public func start() async throws {
        status = .running
        await logger.info("WorkflowAgent started")
    }
    
    public func stop() async {
        status = .stopped
        await logger.info("WorkflowAgent stopped")
    }
    
    public func handle(_ request: AgentRequest) async -> AgentResult {
        await logger.info("Handling request: \(request.action)")
        
        switch request.action {
        case "start":
            let project = request.parameters["project"]
            return await startSession(project: project)
            
        case "done":
            guard let task = request.parameters["task"] else {
                return .failure("No task specified")
            }
            return await completeTask(task: task)
            
        case "note":
            guard let note = request.parameters["note"] else {
                return .failure("No note provided")
            }
            return await addNote(note: note)
            
        case "end":
            return await endSession()
            
        case "status":
            return await getStatus()
            
        default:
            return .failure("Unknown action: \(request.action)")
        }
    }
    
    private func startSession(project: String?) async -> AgentResult {
        let projectName = project ?? "Current Project"
        
        // Check if continuing from previous session
        if let existing = currentSession {
            let daysSince = Calendar.current.dateComponents([.day], from: existing.startedAt, to: Date()).day ?? 0
            
            if daysSince == 0 {
                return .success("""
                ⚡ Welcome back!
                
                Continuing: \(existing.projectName)
                Started: \(formatTime(existing.startedAt))
                
                ✅ Completed: \(existing.completedTasks.count) tasks
                📝 Notes: \(existing.notes.count)
                
                Keep going! 💪
                """)
            }
        }
        
        // Start new session
        currentSession = WorkSession(
            projectName: projectName,
            startedAt: Date(),
            completedTasks: [],
            notes: []
        )
        
        saveSession()
        
        return .success("""
        🚀 Starting your day!
        
        Project: \(projectName)
        Time: \(formatTime(Date()))
        
        Commands you can use:
        • mini done "task"     - Complete a task
        • mini note "thought"  - Capture an idea
        • mini status          - Check progress
        • mini end             - End your session
        
        Let's build! 💪
        """)
    }
    
    private func completeTask(task: String) async -> AgentResult {
        guard var session = currentSession else {
            return .failure("No active session. Start with: mini start")
        }
        
        let completedTask = CompletedTask(
            description: task,
            completedAt: Date()
        )
        
        session.completedTasks.append(completedTask)
        currentSession = session
        saveSession()
        
        await logger.info("Task completed: \(task)")
        
        return .success("""
        ✅ Task completed!
        
        "\(task)"
        
        Total today: \(session.completedTasks.count) tasks
        Time: \(formatTime(Date()))
        
        What's next? 🚀
        """)
    }
    
    private func addNote(note: String) async -> AgentResult {
        guard var session = currentSession else {
            return .failure("No active session. Start with: mini start")
        }
        
        let sessionNote = SessionNote(
            content: note,
            capturedAt: Date()
        )
        
        session.notes.append(sessionNote)
        currentSession = session
        saveSession()
        
        await logger.info("Note captured: \(note)")
        
        return .success("""
        📝 Note captured!
        
        "\(note)"
        
        Total notes today: \(session.notes.count)
        """)
    }
    
    private func endSession() async -> AgentResult {
        guard let session = currentSession else {
            return .failure("No active session")
        }
        
        let duration = Date().timeIntervalSince(session.startedAt)
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        let summary = """
        🎉 Session complete!
        
        Project: \(session.projectName)
        Duration: \(hours)h \(minutes)m
        
        ✅ Completed Tasks (\(session.completedTasks.count)):
        \(session.completedTasks.map { "• \($0.description)" }.joined(separator: "\n"))
        
        📝 Notes Captured (\(session.notes.count)):
        \(session.notes.map { "• \($0.content)" }.joined(separator: "\n"))
        
        Great work today! 🌟
        
        Session saved to: ~/.mini/workflow/
        """
        
        // Archive session
        archiveSession(session)
        currentSession = nil
        saveSession()
        
        return .success(summary)
    }
    
    private func getStatus() async -> AgentResult {
        guard let session = currentSession else {
            return .success("""
            No active session.
            
            Start working with: mini start [project]
            """)
        }
        
        let duration = Date().timeIntervalSince(session.startedAt)
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        return .success("""
        📊 Current Session
        
        Project: \(session.projectName)
        Started: \(formatTime(session.startedAt))
        Duration: \(hours)h \(minutes)m
        
        ✅ Completed: \(session.completedTasks.count) tasks
        📝 Notes: \(session.notes.count)
        
        Recent tasks:
        \(session.completedTasks.suffix(3).map { "• \($0.description)" }.joined(separator: "\n"))
        
        Keep going! 💪
        """)
    }
    
    // MARK: - Persistence
    
    private func loadSession() {
        let url = sessionURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            currentSession = try JSONDecoder().decode(WorkSession.self, from: data)
        } catch {
            // Silent fail, start fresh
        }
    }
    
    private func saveSession() {
        let url = sessionURL()
        
        do {
            if let session = currentSession {
                let encoded = try JSONEncoder().encode(session)
                try encoded.write(to: url)
            } else {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            // Silent fail
        }
    }
    
    private func archiveSession(_ session: WorkSession) {
        let archiveDir = workflowDir().appendingPathComponent("archive")
        try? FileManager.default.createDirectory(at: archiveDir, withIntermediateDirectories: true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let filename = "session-\(formatter.string(from: session.startedAt)).json"
        let archiveURL = archiveDir.appendingPathComponent(filename)
        
        do {
            let encoded = try JSONEncoder().encode(session)
            try encoded.write(to: archiveURL)
        } catch {
            // Silent fail
        }
    }
    
    private func workflowDir() -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".mini/workflow")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    private func sessionURL() -> URL {
        workflowDir().appendingPathComponent("current.json")
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct WorkSession: Codable {
    let projectName: String
    let startedAt: Date
    var completedTasks: [CompletedTask]
    var notes: [SessionNote]
}

struct CompletedTask: Codable {
    let description: String
    let completedAt: Date
}

struct SessionNote: Codable {
    let content: String
    let capturedAt: Date
}
