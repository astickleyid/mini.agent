# Contributing to mini.agent

Thank you for considering contributing to mini.agent! This document provides guidelines and instructions for contributing.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

---

## Code of Conduct

This project and everyone participating in it is governed by mutual respect and professionalism. Please be kind and courteous.

---

## Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later with Command Line Tools
- Swift 5.9+
- Git

### Setting Up Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/mini.agent.git
   cd mini.agent
   ```

2. **Install Dependencies**
   ```bash
   # Install SwiftLint (optional but recommended)
   brew install swiftlint
   ```

3. **Build the Project**
   ```bash
   swift build
   ```

4. **Run the CLI**
   ```bash
   .build/debug/mini --help
   ```

---

## Development Workflow

### Branch Strategy

- `main` - Stable release branch
- `develop` - Development branch (default)
- `feature/*` - Feature branches
- `fix/*` - Bug fix branches
- `docs/*` - Documentation branches

### Creating a Branch

```bash
# For a new feature
git checkout -b feature/my-new-feature

# For a bug fix
git checkout -b fix/issue-123

# For documentation
git checkout -b docs/update-readme
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

**Examples:**
```bash
git commit -m "feat(cli): add logs command to view agent logs"
git commit -m "fix(builder): resolve timeout issue in SwiftPM builds"
git commit -m "docs: update QUICKSTART with new commands"
```

---

## Coding Standards

### Swift Style Guide

- Use Swift's standard naming conventions
- Prefer `let` over `var` when possible
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and single-purpose

### Code Organization

```swift
// 1. Imports
import Foundation
import XPCShared

// 2. Type definition
class MyClass {
    
    // 3. Properties
    private let property: String
    
    // 4. Initialization
    init(property: String) {
        self.property = property
    }
    
    // 5. Public methods
    func publicMethod() { }
    
    // 6. Private methods
    private func privateMethod() { }
}
```

### SwiftLint

Run SwiftLint before committing:

```bash
swiftlint
```

Fix auto-fixable issues:

```bash
swiftlint --fix
```

---

## Testing

### Manual Testing

Test your changes thoroughly:

```bash
# Build
swift build

# Test CLI commands
.build/debug/mini --help
.build/debug/mini --version
.build/debug/mini config

# Test with a real project (if agents are running)
mini init /path/to/test/project
mini build
mini test
```

### Automated Tests

When adding new features, consider adding tests (future work):

```bash
swift test
```

---

## Submitting Changes

### Pull Request Process

1. **Update Documentation**
   - Update README.md if adding new features
   - Update CHANGELOG.md with your changes
   - Update relevant documentation files

2. **Self-Review**
   - Review your own code
   - Test all changes
   - Run SwiftLint
   - Ensure builds succeed

3. **Create Pull Request**
   - Use the PR template
   - Provide clear description
   - Link related issues
   - Add screenshots if applicable

4. **Address Feedback**
   - Respond to review comments
   - Make requested changes
   - Keep PR up to date with base branch

### PR Checklist

Before submitting:

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] CHANGELOG.md updated
- [ ] Builds successfully
- [ ] Tested manually

---

## Reporting Issues

### Bug Reports

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md):

- Describe the bug clearly
- Provide steps to reproduce
- Include environment details
- Attach relevant logs
- Suggest possible solutions

### Feature Requests

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md):

- Describe the feature
- Explain the problem it solves
- Propose a solution
- Provide example usage

### Documentation Issues

Use the [Documentation template](.github/ISSUE_TEMPLATE/documentation.md):

- Identify what needs improvement
- Suggest improvements
- Provide context

---

## Project Structure

```
mini.agent/
├── XPCShared/           # Shared framework
│   ├── AgentRequest.swift
│   ├── AgentResponse.swift
│   ├── AgentError.swift
│   ├── Configuration.swift
│   └── Logger.swift
├── CLI/mini/            # Command-line tool
│   ├── main.swift
│   ├── CommandRouter.swift
│   └── MiniClient.swift
├── Agents/              # XPC services
│   ├── BuilderAgent/
│   ├── DebuggerAgent/
│   ├── MemoryAgent/
│   ├── RepoAgent/
│   ├── TestAgent/
│   ├── TerminalProxyAgent/
│   └── SupervisorAgent/
├── macOSApp/            # SwiftUI dashboard
├── LaunchAgents/        # launchd plists
└── .github/             # GitHub config
    ├── workflows/       # CI/CD workflows
    └── ISSUE_TEMPLATE/  # Issue templates
```

---

## Development Tips

### Debugging

1. **Enable verbose output:**
   ```bash
   swift build -v
   ```

2. **Check agent logs:**
   ```bash
   mini logs <agent-name>
   # or
   tail -f ~/.mini/logs/<agent>/runtime.log
   ```

3. **Use Xcode for debugging:**
   ```bash
   open Package.swift
   # Set breakpoints and debug
   ```

### Performance Profiling

```bash
# Build with optimization reports
swift build -c release \
  -Xswiftc -Rpass-missed=inline \
  -Xswiftc -Rpass=inline
```

---

## Release Process

Maintainers follow this process for releases:

1. Update CHANGELOG.md
2. Update version in code
3. Create and push tag: `git tag v1.0.0`
4. GitHub Actions builds and creates release
5. Verify release artifacts

---

## Getting Help

- **Documentation**: Read [README.md](README.md), [QUICKSTART.md](QUICKSTART.md)
- **Issues**: Search [existing issues](https://github.com/yourusername/mini.agent/issues)
- **Discussions**: Start a [discussion](https://github.com/yourusername/mini.agent/discussions)

---

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for their contributions
- GitHub contributors page
- Release notes

---

## Questions?

If you have questions about contributing, feel free to:
- Open a discussion
- Comment on an issue
- Reach out to maintainers

---

**Thank you for contributing to mini.agent! 🚀**
