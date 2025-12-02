import Foundation

public struct MiniConfiguration: Codable {
    public let projectPath: String
    public let logsPath: String
    public let memoryPath: String
    
    public init(projectPath: String, logsPath: String, memoryPath: String) {
        self.projectPath = projectPath
        self.logsPath = logsPath
        self.memoryPath = memoryPath
    }
    
    private static func baseDirectory() -> URL {
        #if os(macOS)
        // On macOS, use the user's home directory
        return FileManager.default.homeDirectoryForCurrentUser
        #else
        // On iOS/tvOS/watchOS, use Application Support directory
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = urls.first ?? FileManager.default.temporaryDirectory
        return appSupport
        #endif
    }
    
    public static var `default`: MiniConfiguration {
        let baseURL = baseDirectory()
        let project = baseURL.appendingPathComponent(".mini/projects/current", isDirectory: true)
        let logs = baseURL.appendingPathComponent(".mini/logs", isDirectory: true)
        let memory = baseURL.appendingPathComponent(".mini/memory", isDirectory: true)
        return MiniConfiguration(
            projectPath: project.path,
            logsPath: logs.path,
            memoryPath: memory.path
        )
    }
    
    private static var configPath: String {
        let baseURL = baseDirectory()
        let configURL = baseURL.appendingPathComponent(".mini/config.json")
        return configURL.path
    }
    
    public static func load() -> MiniConfiguration {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let config = try? JSONDecoder().decode(MiniConfiguration.self, from: data) else {
            return .default
        }
        return config
    }
    
    public func save() throws {
        let miniDir = Self.baseDirectory().appendingPathComponent(".mini", isDirectory: true)
        
        try FileManager.default.createDirectory(at: miniDir, withIntermediateDirectories: true)
        
        let data = try JSONEncoder().encode(self)
        try data.write(to: URL(fileURLWithPath: Self.configPath))
    }
}
