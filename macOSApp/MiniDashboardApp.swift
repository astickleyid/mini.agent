import SwiftUI

@main
struct MiniDashboardApp: App {

    @State private var firstRunComplete: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if firstRunComplete {
                    DashboardView()
                } else {
                    FirstRunWizard()
                        .onChange(of: firstRunFlag()) { _ in
                            firstRunComplete = firstRunFlag()
                        }
                        .onAppear {
                            firstRunComplete = firstRunFlag()
                        }
                }
            }
        }
    }

    private func firstRunFlag() -> Bool {
        let marker = FileManager.default.homeDirectoryForCurrentUser
            .appending(path: ".mini/first_run_complete")
        return FileManager.default.fileExists(atPath: marker.path)
    }
}
