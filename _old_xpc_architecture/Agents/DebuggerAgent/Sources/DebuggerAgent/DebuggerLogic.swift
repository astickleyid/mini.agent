import Foundation

class DebuggerLogic {

    private let log = Logger(agent: "debugger")

    func analyzeCrashLog(_ crash: String) -> String {

        log.info("Parsing crash log...")

        let stack = StacktraceFormatter().format(crash)
        let parsed = CrashLogParser().parse(crash)

        return """
🐞 Debugger Output
------------------------

Crash Summary:
\(parsed.summary)

Signals:
\(parsed.signal)

Stacktrace (cleaned):
\(stack)

------------------------
"""
    }
}
