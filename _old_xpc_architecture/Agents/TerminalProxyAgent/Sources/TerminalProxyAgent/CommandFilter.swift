import Foundation

class CommandFilter {

    private let allowedPrefixes = [
        "ls",
        "cat",
        "swift build",
        "swift test",
        "git",
        "pwd",
        "echo",
        "cd",
        "du",
        "df",
        "ps",
        "kill -0",
        "whoami",
        "env"
    ]

    func isAllowed(_ cmd: String) -> Bool {

        let forbidden = [
            "rm -rf",
            "shutdown",
            "reboot",
            "mkfs",
            "diskutil erase",
            "kill -9",
            "> /",
            ":(){:|:&};:"
        ]

        for bad in forbidden {
            if cmd.contains(bad) { return false }
        }

        for prefix in allowedPrefixes {
            if cmd.starts(with: prefix) { return true }
        }

        return false
    }
}
