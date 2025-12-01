import SwiftUI
import XPCShared

class DashboardModel: ObservableObject {

    @Published var terminalOutput: String = ""
    @Published var statusItems: [String] = []

    private let client = MiniClient()

    func refresh() {
        checkSupervisor()
    }

    func runBuild() {
        terminalOutput = client.send(.build)
    }

    func runTests() {
        terminalOutput = client.send(.test)
    }

    func checkSupervisor() {
        terminalOutput = client.send(.heartbeat)
        self.statusItems = terminalOutput.split(separator: "\n").map { String($0) }
    }
}
