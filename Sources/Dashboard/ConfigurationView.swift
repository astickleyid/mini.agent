import SwiftUI

struct ConfigurationView: View {
    @StateObject private var config = ConfigurationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "gearshape.2.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text("Configuration")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
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
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
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
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
}

// MARK: - AI Tools Configuration

struct AIToolsConfigView: View {
    @StateObject private var config = ConfigurationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("AI Tool Integration")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // GitHub Copilot
                AIToolCard(
                    name: "GitHub Copilot",
                    iconName: "terminal.fill",
                    iconColor: .green,
                    enabled: $config.copilotEnabled,
                    command: $config.copilotCommand,
                    description: "Best for code generation"
                )
                
                // Gemini
                AIToolCard(
                    name: "Google Gemini",
                    iconName: "sparkles",
                    iconColor: .blue,
                    enabled: $config.geminiEnabled,
                    command: $config.geminiCommand,
                    description: "Fast answers and explanations"
                )
                
                // OpenAI
                AIToolCard(
                    name: "OpenAI",
                    iconName: "cpu",
                    iconColor: .purple,
                    enabled: $config.openaiEnabled,
                    command: $config.openaiCommand,
                    apiKey: $config.openaiApiKey,
                    description: "GPT-4 for complex reasoning"
                )
                
                // Ollama (Local)
                AIToolCard(
                    name: "Ollama",
                    iconName: "server.rack",
                    iconColor: .orange,
                    enabled: $config.ollamaEnabled,
                    command: $config.ollamaCommand,
                    description: "Local models, no API needed"
                )
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Routing Preferences
            VStack(alignment: .leading, spacing: 16) {
                Text("Smart Routing")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Default AI:")
                            .frame(width: 140, alignment: .trailing)
                        Picker("", selection: $config.defaultAI) {
                            Text("Copilot").tag("copilot")
                            Text("Gemini").tag("gemini")
                            Text("OpenAI").tag("openai")
                            Text("Ollama").tag("ollama")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Code generation:")
                            .frame(width: 140, alignment: .trailing)
                        Picker("", selection: $config.codeGenerationAI) {
                            Text("Copilot").tag("copilot")
                            Text("OpenAI").tag("openai")
                            Text("Ollama").tag("ollama")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Questions/Chat:")
                            .frame(width: 140, alignment: .trailing)
                        Picker("", selection: $config.questionsAI) {
                            Text("Gemini").tag("gemini")
                            Text("OpenAI").tag("openai")
                            Text("Ollama").tag("ollama")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            Button("Test All Connections") {
                config.testAllConnections()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
}

struct AIToolCard: View {
    let name: String
    let iconName: String
    let iconColor: Color
    @Binding var enabled: Bool
    @Binding var command: String
    var apiKey: Binding<String>? = nil
    let description: String
    
    @State private var isExpanded = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 40)
                    .accessibilityLabel("\(name) icon")
                
                // Name and Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: $enabled)
                    .labelsHidden()
                    .accessibilityLabel("Enable \(name)")
                
                // Expand button
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
            }
            .padding(16)
            
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Text("CLI Command:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .trailing)
                        TextField("e.g., gh copilot", text: $command)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    if let apiKeyBinding = apiKey {
                        HStack(spacing: 8) {
                            Text("API Key:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 100, alignment: .trailing)
                            SecureField("Optional", text: apiKeyBinding)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button("Test Connection") {
                            // Test this specific tool
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(16)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(isHovered ? 0.1 : 0.05), radius: 4, x: 0, y: 2)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Commands Configuration

struct CommandsConfigView: View {
    @StateObject private var config = ConfigurationManager.shared
    @State private var showAddCommand = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Custom Commands")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showAddCommand = true }) {
                    Label("Add Command", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            
            if config.customCommands.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No custom commands yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Create shortcuts for your common workflows")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(60)
            } else {
                VStack(spacing: 16) {
                    ForEach(config.customCommands) { command in
                        CustomCommandCard(command: command)
                    }
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showAddCommand) {
            AddCommandView()
        }
    }
}

struct CustomCommandCard: View {
    let command: CustomCommand
    @State private var isExpanded = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                    .frame(width: 40)
                
                // Name and Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(command.name)
                        .font(.headline)
                    Text(command.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shortcut:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("mini \(command.shortcut)")
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Action:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(command.action)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 12) {
                        Button("Run") {
                            // Execute command
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Edit") {
                            // Edit command
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Delete", role: .destructive) {
                            // Delete command
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(16)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(isHovered ? 0.1 : 0.05), radius: 4, x: 0, y: 2)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct AddCommandView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var shortcut = ""
    @State private var description = ""
    @State private var action = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Command Name", text: $name)
                    TextField("Shortcut (e.g., 'auth')", text: $shortcut)
                    TextField("Description", text: $description)
                }
                
                Section("Action") {
                    TextEditor(text: $action)
                        .frame(minHeight: 120)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("What this command should do in plain English")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)
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
        .frame(width: 500, height: 450)
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
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .accentColor : .secondary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? Color.accentColor.opacity(0.1) : Color.clear
                )
        }
        .buttonStyle(.plain)
    }
}

struct ProjectsConfigView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Project Management")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                
                Text("Project management coming soon")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Manage your coding projects, track progress, and organize your workspace")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }
            .frame(maxWidth: .infinity)
            .padding(60)
            
            Spacer()
        }
    }
}

struct PreferencesConfigView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("General Preferences")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                
                Text("Preferences coming soon")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Configure app settings, themes, keyboard shortcuts, and more")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }
            .frame(maxWidth: .infinity)
            .padding(60)
            
            Spacer()
        }
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
}

#Preview {
    ConfigurationView()
}
