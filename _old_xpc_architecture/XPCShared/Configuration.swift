import Foundation

public struct MiniConfiguration: Codable {
    public let projectPath: String
    public let logsPath: String
    public let memoryPath: String
    public let agentsPath: String
    
    public init(projectPath: String, logsPath: String, memoryPath: String, agentsPath: String) {
        self.projectPath = projectPath
        self.logsPath = logsPath
        self.memoryPath = memoryPath
        self.agentsPath = agentsPath
    }
    
    public static var `default`: MiniConfiguration {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return MiniConfiguration(
            projectPath: "\(home)/.mini/projects/current",
            logsPath: "\(home)/.mini/logs",
            memoryPath: "\(home)/.mini/memory",
            agentsPath: "\(home)/.mini/agents"
        )
    }
    
    public static func load() -> MiniConfiguration {
        let configPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/config.json")
        
        guard let data = try? Data(contentsOf: configPath),
              let config = try? sharedJSONDecoder.decode(MiniConfiguration.self, from: data) else {
            return .default
        }
        return config
    }
    
    public func save() throws {
        let configPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/config.json")
        
        let miniDir = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini")
        
        try? FileManager.default.createDirectory(at: miniDir, withIntermediateDirectories: true)
        
        let data = try sharedJSONEncoder.encode(self)
        try data.write(to: configPath)
    }
}
