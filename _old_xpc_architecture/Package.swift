// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "mini-agent",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MiniAgentCore",
            targets: ["MiniAgentCore"]
        ),
        .library(
            name: "Agents",
            targets: ["Agents"]
        ),
        .executable(
            name: "mini",
            targets: ["CLI"]
        ),
        .executable(
            name: "MiniDashboard",
            targets: ["Dashboard"]
        )
    ],
    targets: [
        .target(
            name: "MiniAgentCore",
            path: "Sources/MiniAgentCore"
        ),
        .target(
            name: "Agents",
            dependencies: ["MiniAgentCore"],
            path: "Sources/Agents"
        ),
        .executableTarget(
            name: "CLI",
            dependencies: ["MiniAgentCore", "Agents"],
            path: "Sources/CLI"
        ),
        .executableTarget(
            name: "Dashboard",
            dependencies: ["MiniAgentCore", "Agents"],
            path: "Sources/Dashboard"
        )
    ]
)
