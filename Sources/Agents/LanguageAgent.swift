import Foundation
import MiniAgentCore

/// Agent for learning and interpreting your custom language/phrases
@available(iOS 13.4, *)
public actor LanguageAgent: Agent {
    public let name = "language"
    public private(set) var status: AgentStatus = .idle
    
    private let logger: Logger
    private let config: MiniConfiguration
    private var definitions: [String: LanguageDefinition] = [:]
    
    public init() {
        self.logger = Logger(agent: "language")
        self.config = MiniConfiguration.load()
        Task {
            await loadDefinitions()
        }
    }
    
    public func start() async throws {
        status = .running
        await logger.info("LanguageAgent started")
        await logger.info("Loaded \(definitions.count) custom definitions")
    }
    
    public func stop() async {
        status = .stopped
        await logger.info("LanguageAgent stopped")
    }
    
    public func handle(_ request: AgentRequest) async -> AgentResult {
        await logger.info("Handling request: \(request.action)")
        
        switch request.action {
        case "define":
            guard let phrase = request.parameters["phrase"],
                  let meaning = request.parameters["meaning"] else {
                return .failure("Missing phrase or meaning")
            }
            let category = request.parameters["category"] ?? "general"
            return await define(phrase: phrase, meaning: meaning, category: category)
            
        case "translate":
            guard let phrase = request.parameters["phrase"] else {
                return .failure("No phrase to translate")
            }
            return await translate(phrase: phrase)
            
        case "list":
            let category = request.parameters["category"]
            return await listDefinitions(category: category)
            
        case "learn":
            guard let phrase = request.parameters["phrase"],
                  let example = request.parameters["example"] else {
                return .failure("Missing phrase or example")
            }
            return await learnFromExample(phrase: phrase, example: example)
            
        default:
            return .failure("Unknown action: \(request.action)")
        }
    }
    
    private func define(phrase: String, meaning: String, category: String) async -> AgentResult {
        let definition = LanguageDefinition(
            phrase: phrase,
            meaning: meaning,
            category: category,
            examples: [],
            createdAt: Date()
        )
        
        definitions[phrase.lowercased()] = definition
        saveDefinitions()
        
        await logger.info("Defined: '\(phrase)' → '\(meaning)'")
        
        return .success("""
        ✅ Learned your language!
        
        Phrase: "\(phrase)"
        Means: \(meaning)
        Category: \(category)
        
        Now when you say "\(phrase)", I'll know what you mean!
        """)
    }
    
    private func translate(phrase: String) async -> AgentResult {
        let lowercased = phrase.lowercased()
        
        // Check for exact match
        if let definition = definitions[lowercased] {
            return .success("""
            💡 I know this!
            
            You said: "\(phrase)"
            That means: \(definition.meaning)
            
            Category: \(definition.category)
            \(definition.examples.isEmpty ? "" : "\nExamples:\n" + definition.examples.joined(separator: "\n"))
            """)
        }
        
        // Check for partial matches
        let matches = definitions.filter { key, _ in
            lowercased.contains(key) || key.contains(lowercased)
        }
        
        if !matches.isEmpty {
            let results = matches.map { key, def in
                "• '\(def.phrase)' → \(def.meaning)"
            }.joined(separator: "\n")
            
            return .success("""
            🔍 Found similar phrases:
            
            \(results)
            
            Is this what you meant?
            """)
        }
        
        return .success("""
        ❓ I don't know "\(phrase)" yet.
        
        Teach me! Use:
        mini define "\(phrase)" "what it means"
        """)
    }
    
    private func listDefinitions(category: String?) async -> AgentResult {
        var defs = Array(definitions.values)
        
        if let category = category {
            defs = defs.filter { $0.category == category }
        }
        
        guard !defs.isEmpty else {
            return .success("No definitions yet. Start teaching me your language!")
        }
        
        let grouped = Dictionary(grouping: defs) { $0.category }
        var output = "📚 YOUR LANGUAGE DEFINITIONS\n\n"
        
        for (category, items) in grouped.sorted(by: { $0.key < $1.key }) {
            output += "[\(category.uppercased())]\n"
            for item in items.sorted(by: { $0.phrase < $1.phrase }) {
                output += "• '\(item.phrase)' → \(item.meaning)\n"
            }
            output += "\n"
        }
        
        return .success(output)
    }
    
    private func learnFromExample(phrase: String, example: String) async -> AgentResult {
        let lowercased = phrase.lowercased()
        
        guard var definition = definitions[lowercased] else {
            return .failure("Phrase '\(phrase)' not defined yet. Define it first with: mini define")
        }
        
        definition.examples.append(example)
        definitions[lowercased] = definition
        saveDefinitions()
        
        return .success("""
        ✅ Added example to '\(phrase)'
        
        Total examples: \(definition.examples.count)
        """)
    }
    
    // MARK: - Persistence
    
    private func loadDefinitions() {
        let url = definitionsURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([String: LanguageDefinition].self, from: data)
            definitions = decoded
        } catch {
            // Silent fail, start fresh
        }
    }
    
    private func saveDefinitions() {
        let url = definitionsURL()
        
        do {
            let encoded = try JSONEncoder().encode(definitions)
            try encoded.write(to: url)
        } catch {
            // Silent fail
        }
    }
    
    private func definitionsURL() -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let miniDir = home.appendingPathComponent(".mini")
        try? FileManager.default.createDirectory(at: miniDir, withIntermediateDirectories: true)
        return miniDir.appendingPathComponent("language.json")
    }
}

struct LanguageDefinition: Codable {
    let phrase: String
    let meaning: String
    let category: String
    var examples: [String]
    let createdAt: Date
}
