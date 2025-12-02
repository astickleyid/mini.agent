import SwiftUI
import AppKit
import MiniAgentCore
import Agents

@main
struct MiniDashboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            FlexibleTabView()
                .frame(minWidth: 900, minHeight: 700)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

struct DashboardView: View {
    @StateObject private var manager = AgentManager.shared
    @State private var output: String = "Welcome to Mini Agent Dashboard\n\nSelect an action to get started..."
    @State private var isProcessing = false
    @State private var commitMessage = ""
    @State private var branchName = ""
    @State private var memoryNote = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            HStack(spacing: 0) {
                // Sidebar
                sidebarView
                    .frame(width: 250)
                
                Divider()
                
                // Main content
                mainContentView
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "cpu.fill")
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
            
            Text("Mini Agent Dashboard")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Circle()
                .fill(manager.isRunning ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            Text(manager.isRunning ? "Running" : "Stopped")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AGENTS")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach(Array(manager.agents.keys.sorted()), id: \.self) { agentName in
                AgentRow(name: agentName, isRunning: manager.isRunning)
            }
            
            Spacer()
        }
        .padding(.vertical)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var mainContentView: some View {
        VStack(spacing: 16) {
            // Actions
            ScrollView {
                VStack(spacing: 12) {
                    actionSection
                    inputSection
                }
                .padding()
            }
            
            Divider()
            
            // Output
            outputView
        }
    }
    
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK ACTIONS")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ActionButton(title: "Build", icon: "hammer.fill", color: .blue) {
                    await runAction("build")
                }
                
                ActionButton(title: "Test", icon: "checkmark.circle.fill", color: .green) {
                    await runAction("test")
                }
                
                ActionButton(title: "Status", icon: "info.circle.fill", color: .orange) {
                    await runAction("status")
                }
                
                ActionButton(title: "List Memory", icon: "book.fill", color: .purple) {
                    await runAction("memory-list")
                }
            }
            .disabled(isProcessing)
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("COMMANDS")
                .font(.headline)
            
            // Commit
            HStack {
                TextField("Commit message", text: $commitMessage)
                    .textFieldStyle(.roundedBorder)
                
                Button("Commit") {
                    Task {
                        await runCommit()
                    }
                }
                .disabled(commitMessage.isEmpty || isProcessing)
            }
            
            // Branch
            HStack {
                TextField("Branch name", text: $branchName)
                    .textFieldStyle(.roundedBorder)
                
                Button("Create Branch") {
                    Task {
                        await createBranch()
                    }
                }
                .disabled(branchName.isEmpty || isProcessing)
            }
            
            // Memory
            HStack {
                TextField("Memory note", text: $memoryNote)
                    .textFieldStyle(.roundedBorder)
                
                Button("Save Note") {
                    Task {
                        await saveMemory()
                    }
                }
                .disabled(memoryNote.isEmpty || isProcessing)
            }
        }
    }
    
    private var outputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("OUTPUT")
                    .font(.headline)
                
                Spacer()
                
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                Text(output)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func runAction(_ action: String) async {
        isProcessing = true
        output = "Processing \(action)...\n"
        
        let result: AgentResult
        
        switch action {
        case "build":
            result = await manager.sendRequest(to: "builder", request: AgentRequest(action: "build"))
        case "test":
            result = await manager.sendRequest(to: "test", request: AgentRequest(action: "test"))
        case "status":
            result = await manager.sendRequest(to: "repo", request: AgentRequest(action: "status"))
        case "memory-list":
            result = await manager.sendRequest(to: "memory", request: AgentRequest(action: "list"))
        default:
            result = .failure("Unknown action")
        }
        
        output = result.success ? result.output : (result.error ?? "Action failed")
        isProcessing = false
    }
    
    private func runCommit() async {
        isProcessing = true
        output = "Creating commit...\n"
        
        let result = await manager.sendRequest(
            to: "repo",
            request: AgentRequest(action: "commit", parameters: ["message": commitMessage])
        )
        
        output = result.success ? result.output : (result.error ?? "Commit failed")
        if result.success {
            commitMessage = ""
        }
        isProcessing = false
    }
    
    private func createBranch() async {
        isProcessing = true
        output = "Creating branch...\n"
        
        let result = await manager.sendRequest(
            to: "repo",
            request: AgentRequest(action: "branch", parameters: ["name": branchName])
        )
        
        output = result.success ? result.output : (result.error ?? "Branch creation failed")
        if result.success {
            branchName = ""
        }
        isProcessing = false
    }
    
    private func saveMemory() async {
        isProcessing = true
        output = "Saving note...\n"
        
        let result = await manager.sendRequest(
            to: "memory",
            request: AgentRequest(action: "save", parameters: ["note": memoryNote])
        )
        
        output = result.success ? result.output : (result.error ?? "Save failed")
        if result.success {
            memoryNote = ""
        }
        isProcessing = false
    }
}

struct AgentRow: View {
    let name: String
    let isRunning: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isRunning ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            
            Text(name.capitalized)
                .font(.system(.body, design: .monospaced))
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.1))
                .foregroundColor(color)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
