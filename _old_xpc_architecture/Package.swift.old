// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "mini-agent",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "XPCShared", targets: ["XPCShared"]),
        .executable(name: "mini", targets: ["mini"]),
        .executable(name: "MiniDashboardApp", targets: ["MiniDashboardApp"])
    ],
    targets: [
        .target(
            name: "XPCShared",
            path: "XPCShared"
        ),
        .executableTarget(
            name: "mini",
            dependencies: ["XPCShared"],
            path: "CLI/mini"
        ),
        .executableTarget(
            name: "MiniDashboardApp",
            dependencies: ["XPCShared"],
            path: "macOSApp"
        )
    ]
)
