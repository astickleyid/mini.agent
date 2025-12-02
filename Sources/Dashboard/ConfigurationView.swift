import SwiftUI

struct ConfigurationView: View {
    @StateObject private var config = ConfigurationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("⚙️ Configuration")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Tabs
            HStack(spacing: 0) {
                TabButton(title: "AI Tools", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "Commands", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Projects", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                TabButton(title: "Preferences", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .background(Color.gray.opacity(0.15))
            
            // Content
            ScrollView {
                Group {
                    switch selectedTab {
                    case 0:
                        AIToolsConfigView()
                    case 1:
                        CommandsConfigView()
                    case 2:
                        ProjectsConfigView()
                    case 3:
                        PreferencesConfigView()
                    default:
                        EmptyView()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - AI Tools Configuration

struct AIToolsConfigView: View {
    @StateObject private var config = ConfigurationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AI Tool Integration")
                .font(.title2)
                .fontWeight(.bold)
            
            // GitHub Copilot
            AIToolCard(
                name: "GitHub Copilot",
                icon: "🤖",
                enabled: $config.copilotEnabled,
                command: $config.copilotCommand,
                description: "Best for code generation"
            )
            
            // Gemini
            AIToolCard(
                name: "Google Gemini",
                icon: "✨",
                enabled: $config.geminiEnabled,
                command: $config.geminiCommand,
                description: "Fast answers and explanations"
            )
            
            // OpenAI
            AIToolCard(
                name: "OpenAI",
                icon: "🧠",
                enabled: $config.openaiEnabled,
                command: $config.openaiCommand,
                apiKey: $config.openaiApiKey,
                description: "GPT-4 for complex reasoning"
            )
            
            // Ollama (Local)
            AIToolCard(
                name: "Ollama",
                icon: "🦙",
                enabled: $config.ollamaEnabled,
                command: $config.ollamaCommand,
                description: "Local models, no API needed"
            )
            
            Divider()
            
            // Routing Preferences
            VStack(alignment: .leading, spacing: 12) {
                Text("Smart Routing")
                    .font(.headline)
                
                HStack {
                    Text("Default AI:")
                    Picker("", selection: $config.defaultAI) {
                        Text("Copilot").tag("copilot")
                        Text("Gemini").tag("gemini")
                        Text("OpenAI").tag("openai")
                        Text("Ollama").tag("ollama")
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("Code generation:")
                    Picker("", selection: $config.codeGenerationAI) {
                        Text("Copilot").tag("copilot")
                        Text("OpenAI").tag("openai")
                        Text("Ollama").tag("ollama")
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("Questions/Chat:")
                    Picker("", selection: $config.questionsAI) {
                        Text("Gemini").tag("gemini")
                        Text("OpenAI").tag("openai")
                        Text("Ollama").tag("ollama")
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            Button("Test All Connections") {
                config.testAllConnections()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct AIToolCard: View {
    let name: String
    let icon: String
    @Binding var enabled: Bool
    @Binding var command: String
    var apiKey: Binding<String>? = nil
    let description: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(icon)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $enabled)
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("CLI Command:")
                            .font(.caption)
                        TextField("e.g., gh copilot", text: $command)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    if let apiKeyBinding = apiKey {
                        HStack {
                            Text("API Key:")
                                .font(.caption)
                            SecureField("Optional", text: apiKeyBinding)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    Button("Test Connection") {
                        // Test this specific tool
                    }
                    .font(.caption)
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Commands Configuration

struct CommandsConfigView: View {
    @StateObject private var config = ConfigurationManager.shared
    @State private var showAddCommand = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Custom Commands")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showAddCommand = true }) {
                    Label("Add Command", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            
            if config.customCommands.isEmpty {
                VStack(spacing: 12) {
                    Text("No custom commands yet")
                        .foregroundColor(.secondary)
                    Text("Create shortcuts for your common workflows")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                ForEach(config.customCommands) { command in
                    CustomCommandCard(command: command)
                }
            }
        }
        .sheet(isPresented: $showAddCommand) {
            AddCommandView()
        }
    }
}

struct CustomCommandCard: View {
    let command: CustomCommand
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(command.icon)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(command.name)
                        .font(.headline)
                    Text(command.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Command: mini \(command.shortcut)")
                        .font(.system(.caption, design: .monospaced))
                        .padding(8)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(4)
                    
                    Text("What it does:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(command.action)
                        .font(.caption)
                    
                    HStack {
                        Button("Run") {
                            // Execute command
                        }
                        Button("Edit") {
                            // Edit command
                        }
                        Button("Delete", role: .destructive) {
                            // Delete command
                        }
                    }
                    .font(.caption)
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct AddCommandView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var shortcut = ""
    @State private var description = ""
    @State private var action = ""
    @State private var icon = "⚡"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Command Name", text: $name)
                    TextField("Shortcut (e.g., 'auth')", text: $shortcut)
                    TextField("Description", text: $description)
                    TextField("Icon", text: $icon)
                }
                
                Section("Action") {
                    TextEditor(text: $action)
                        .frame(minHeight: 100)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("What this command should do in plain English")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Custom Command")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save command
                        dismiss()
                    }
                    .disabled(name.isEmpty || shortcut.isEmpty || action.isEmpty)
                }
            }
        }
    }
}

// MARK: - Helper Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .primary : .secondary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

struct ProjectsConfigView: View {
    var body: some View {
        Text("Projects Config - TODO")
    }
}

struct PreferencesConfigView: View {
    var body: some View {
        Text("Preferences - TODO")
    }
}

// MARK: - Configuration Manager

class ConfigurationManager: ObservableObject {
    static let shared = ConfigurationManager()
    
    // AI Tools
    @Published var copilotEnabled = true
    @Published var copilotCommand = "gh copilot"
    
    @Published var geminiEnabled = true
    @Published var geminiCommand = "gemini"
    
    @Published var openaiEnabled = false
    @Published var openaiCommand = "openai"
    @Published var openaiApiKey = ""
    
    @Published var ollamaEnabled = false
    @Published var ollamaCommand = "ollama"
    
    // Routing
    @Published var defaultAI = "copilot"
    @Published var codeGenerationAI = "copilot"
    @Published var questionsAI = "gemini"
    
    // Custom Commands
    @Published var customCommands: [CustomCommand] = []
    
    func testAllConnections() {
        // Test all enabled AI tools
    }
    
    func save() {
        // Save to ~/.mini/config.json
    }
    
    func load() {
        // Load from ~/.mini/config.json
    }
}

struct CustomCommand: Identifiable {
    let id = UUID()
    let name: String
    let shortcut: String
    let description: String
    let action: String
    let icon: String
}

#Preview {
    ConfigurationView()
}
