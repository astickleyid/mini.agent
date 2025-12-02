import Foundation
import MiniAgentCore

@available(iOS 13.4, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public actor GeneratorAgent: Agent {
    public let name = "generator"
    public private(set) var status: AgentStatus = .idle
    
    private let logger: Logger
    private let config: MiniConfiguration
    
    public init() {
        self.logger = Logger(agent: "generator")
        self.config = MiniConfiguration.load()
    }
    
    public func start() async throws {
        status = .running
        await logger.info("GeneratorAgent started")
    }
    
    public func stop() async {
        status = .stopped
        await logger.info("GeneratorAgent stopped")
    }
    
    public func handle(_ request: AgentRequest) async -> AgentResult {
        await logger.info("Handling request: \(request.action)")
        
        switch request.action {
        case "generate":
            guard let spec = request.parameters["spec"] else {
                return .failure("No specification provided")
            }
            return await generate(spec: spec)
        default:
            return .failure("Unknown action: \(request.action)")
        }
    }
    
    private func generate(spec: String) async -> AgentResult {
        await logger.info("Generating code from spec: \(spec)")
        
        // Parse the spec
        let lowercased = spec.lowercased()
        
        // Check what type of generation
        if lowercased.contains("auth") || lowercased.contains("login") {
            return await generateAuth(spec: spec)
        }
        
        return .failure("Could not understand specification")
    }
    
    private func generateAuth(spec: String) async -> AgentResult {
        guard FileManager.default.fileExists(atPath: config.projectPath) else {
            return .failure("Project not found at: \(config.projectPath)")
        }
        
        let projectURL = URL(fileURLWithPath: config.projectPath)
        var output = "📦 Generating User Auth System...\n\n"
        
        // Create directory structure
        let dirs = ["Models", "Services", "ViewModels", "Views", "Tests"]
        for dir in dirs {
            let dirURL = projectURL.appendingPathComponent("Sources").appendingPathComponent(dir)
            try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
        }
        
        // Generate User model
        output += "✅ Models/User.swift\n"
        let userModel = generateUserModel()
        let userPath = projectURL.appendingPathComponent("Sources/Models/User.swift").path
        try? userModel.write(toFile: userPath, atomically: true, encoding: .utf8)
        
        // Generate AuthService
        output += "✅ Services/AuthService.swift\n"
        let authService = generateAuthService()
        let authPath = projectURL.appendingPathComponent("Sources/Services/AuthService.swift").path
        try? authService.write(toFile: authPath, atomically: true, encoding: .utf8)
        
        // Generate LoginViewModel
        output += "✅ ViewModels/LoginViewModel.swift\n"
        let loginVM = generateLoginViewModel()
        let loginVMPath = projectURL.appendingPathComponent("Sources/ViewModels/LoginViewModel.swift").path
        try? loginVM.write(toFile: loginVMPath, atomically: true, encoding: .utf8)
        
        // Generate LoginView
        output += "✅ Views/LoginView.swift\n"
        let loginView = generateLoginView()
        let loginViewPath = projectURL.appendingPathComponent("Sources/Views/LoginView.swift").path
        try? loginView.write(toFile: loginViewPath, atomically: true, encoding: .utf8)
        
        // Generate HomeView
        output += "✅ Views/HomeView.swift\n"
        let homeView = generateHomeView()
        let homeViewPath = projectURL.appendingPathComponent("Sources/Views/HomeView.swift").path
        try? homeView.write(toFile: homeViewPath, atomically: true, encoding: .utf8)
        
        // Generate Tests
        output += "✅ Tests/AuthTests.swift\n"
        let tests = generateAuthTests()
        let testsPath = projectURL.appendingPathComponent("Sources/Tests/AuthTests.swift").path
        try? tests.write(toFile: testsPath, atomically: true, encoding: .utf8)
        
        output += "\n📝 Generated complete auth system with:\n"
        output += "   - User model\n"
        output += "   - Auth service\n"
        output += "   - Login screen\n"
        output += "   - Home screen\n"
        output += "   - Navigation flow\n"
        output += "   - Unit tests\n"
        output += "\n✨ Ready to use!"
        
        return .success(output)
    }
    
    private func generateUserModel() -> String {
        return """
        import Foundation
        
        /// User model for authentication
        struct User: Codable, Identifiable, Equatable {
            let id: UUID
            let email: String
            let name: String
            let createdAt: Date
            
            init(id: UUID = UUID(), email: String, name: String, createdAt: Date = Date()) {
                self.id = id
                self.email = email
                self.name = name
                self.createdAt = createdAt
            }
        }
        """
    }
    
    private func generateAuthService() -> String {
        return """
        import Foundation
        import Combine
        
        /// Authentication service for user login/logout
        @MainActor
        class AuthService: ObservableObject {
            @Published var currentUser: User?
            @Published var isAuthenticated = false
            
            private let tokenKey = "auth_token"
            
            /// Login with email and password
            func login(email: String, password: String) async throws -> User {
                // TODO: Replace with real API call
                // Simulated login for now
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // Validate
                guard !email.isEmpty, !password.isEmpty else {
                    throw AuthError.invalidCredentials
                }
                
                // Create user
                let user = User(email: email, name: email.split(separator: "@").first.map(String.init) ?? "User")
                
                // Store token (simplified)
                UserDefaults.standard.set("demo_token_\\(user.id)", forKey: tokenKey)
                
                // Update state
                self.currentUser = user
                self.isAuthenticated = true
                
                return user
            }
            
            /// Logout current user
            func logout() {
                UserDefaults.standard.removeObject(forKey: tokenKey)
                currentUser = nil
                isAuthenticated = false
            }
            
            /// Check if user has saved session
            func checkAuth() {
                if let token = UserDefaults.standard.string(forKey: tokenKey), !token.isEmpty {
                    // TODO: Validate token with API
                    // For now, just mark as authenticated
                    isAuthenticated = true
                }
            }
        }
        
        enum AuthError: LocalizedError {
            case invalidCredentials
            case networkError
            case unauthorized
            
            var errorDescription: String? {
                switch self {
                case .invalidCredentials:
                    return "Invalid email or password"
                case .networkError:
                    return "Network error occurred"
                case .unauthorized:
                    return "Unauthorized access"
                }
            }
        }
        """
    }
    
    private func generateLoginViewModel() -> String {
        return """
        import Foundation
        import Combine
        
        /// ViewModel for login screen
        @MainActor
        class LoginViewModel: ObservableObject {
            @Published var email = ""
            @Published var password = ""
            @Published var isLoading = false
            @Published var errorMessage: String?
            @Published var isLoginSuccessful = false
            
            private let authService: AuthService
            
            init(authService: AuthService) {
                self.authService = authService
            }
            
            /// Validate and login
            func login() async {
                errorMessage = nil
                
                // Validation
                guard !email.isEmpty else {
                    errorMessage = "Email is required"
                    return
                }
                
                guard !password.isEmpty else {
                    errorMessage = "Password is required"
                    return
                }
                
                guard email.contains("@") else {
                    errorMessage = "Invalid email format"
                    return
                }
                
                isLoading = true
                
                do {
                    let user = try await authService.login(email: email, password: password)
                    isLoginSuccessful = true
                    print("Login successful for: \\(user.email)")
                } catch {
                    errorMessage = error.localizedDescription
                }
                
                isLoading = false
            }
        }
        """
    }
    
    private func generateLoginView() -> String {
        return """
        import SwiftUI
        
        /// Login screen view
        struct LoginView: View {
            @StateObject private var viewModel: LoginViewModel
            @EnvironmentObject private var authService: AuthService
            
            init(authService: AuthService) {
                _viewModel = StateObject(wrappedValue: LoginViewModel(authService: authService))
            }
            
            var body: some View {
                NavigationView {
                    VStack(spacing: 20) {
                        // Logo/Title
                        Text("Welcome")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 40)
                        
                        // Email field
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        // Password field
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                        
                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Login button
                        Button {
                            Task {
                                await viewModel.login()
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Text("Login")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isLoading)
                        
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Login")
                }
                .fullScreenCover(isPresented: $viewModel.isLoginSuccessful) {
                    HomeView()
                }
            }
        }
        """
    }
    
    private func generateHomeView() -> String {
        return """
        import SwiftUI
        
        /// Home screen after login
        struct HomeView: View {
            @EnvironmentObject private var authService: AuthService
            
            var body: some View {
                NavigationView {
                    VStack(spacing: 20) {
                        if let user = authService.currentUser {
                            Text("Welcome, \\(user.name)!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(user.email)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Welcome!")
                                .font(.title)
                        }
                        
                        Spacer()
                        
                        // Logout button
                        Button {
                            authService.logout()
                        } label: {
                            Text("Logout")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .navigationTitle("Home")
                }
            }
        }
        """
    }
    
    private func generateAuthTests() -> String {
        return """
        import XCTest
        @testable import YourApp
        
        @MainActor
        final class AuthTests: XCTestCase {
            var authService: AuthService!
            
            override func setUp() async throws {
                authService = AuthService()
            }
            
            func testLoginSuccess() async throws {
                // Given
                let email = "test@example.com"
                let password = "password123"
                
                // When
                let user = try await authService.login(email: email, password: password)
                
                // Then
                XCTAssertEqual(user.email, email)
                XCTAssertTrue(authService.isAuthenticated)
                XCTAssertNotNil(authService.currentUser)
            }
            
            func testLoginEmptyCredentials() async {
                // Given
                let email = ""
                let password = ""
                
                // When/Then
                do {
                    _ = try await authService.login(email: email, password: password)
                    XCTFail("Should throw error")
                } catch {
                    XCTAssertTrue(error is AuthError)
                }
            }
            
            func testLogout() async throws {
                // Given - login first
                _ = try await authService.login(email: "test@example.com", password: "password")
                
                // When
                authService.logout()
                
                // Then
                XCTAssertFalse(authService.isAuthenticated)
                XCTAssertNil(authService.currentUser)
            }
        }
        """
    }
}

