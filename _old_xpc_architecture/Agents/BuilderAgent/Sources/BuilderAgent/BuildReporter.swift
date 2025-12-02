import Foundation

class BuildReporter {

    func render(buildOutput: String,
                diagnostics: [BuildDiagnostic]) -> String {

        var report = """
🏗️ Build Report
------------------------
Raw Output:
\(buildOutput)

Diagnostics:
"""

        for diag in diagnostics {
            report += "\n\n• \(diag.isError ? "❌ ERROR" : "⚠️ Warning")"
            report += "\n  File: \(diag.file)"
            report += "\n  Line: \(diag.line)"
            report += "\n  Message: \(diag.message)"
        }

        if diagnostics.isEmpty {
            report += "\n\n🎉 No errors detected!"
        }

        return report + "\n\n------------------------"
    }
}
