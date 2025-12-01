import Foundation

class RepoLogic {

    private let log = Logger(agent: "repo")
    private let git = GitRunner()
    private let projectPath: String

    init() {
        self.projectPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".mini/projects/current")
            .path
    }

    func commit(message: String) -> String {

        guard FileManager.default.fileExists(atPath: projectPath) else {
            return "Repo error: project folder not found at \(projectPath)"
        }

        log.info("Running git add ...")
        let add = git.run("git add -A", at: projectPath)

        log.info("Running git commit ...")
        let commit = git.run("git commit -m \"\(message)\"", at: projectPath)

        return """
📝 Commit Completed
        -------------------
        git add:
        \(add)

        git commit:
        \(commit)
        """
    }

    func branch(name: String) -> String {

        guard FileManager.default.fileExists(atPath: projectPath) else {
            return "Repo error: project folder not found at \(projectPath)"
        }

        log.info("Creating branch: \(name)")
        let output = git.run("git checkout -b \(name)", at: projectPath)

        return """
🌿 Branch Created
        ------------------
        Name: \(name)
        Output:
        \(output)
        """
    }

    func push(remote: String = "origin", branch: String = "main") -> String {

        let cmd = "git push \(remote) \(branch)"
        log.info("Executing: \(cmd)")

        let output = git.run(cmd, at: projectPath)

        return """
⬆️ Push Completed
        ------------------
        \(output)
        """
    }

    func pull(remote: String = "origin", branch: String = "main") -> String {

        let cmd = "git pull \(remote) \(branch)"
        log.info("Executing: \(cmd)")

        let output = git.run(cmd, at: projectPath)

        return """
⬇️ Pull Completed
        ------------------
        \(output)
        """
    }

    func status() -> String {

        let output = git.run("git status --short --branch", at: projectPath)

        return """
📌 Repo Status
        ------------------
        \(output)
        """
    }
}
