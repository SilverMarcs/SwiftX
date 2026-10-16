// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BirdieCore",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "BirdieCore", targets: ["BirdieCore"])],
    targets: [
        .target(
            name: "BirdieCore",
            path: "Birdie",
            exclude: [
                "Assets.xcassets", "AppIcon.icon", "Views", "BirdieApp.swift", "ContentView.swift",
                "Models/NavigationDestination.swift", "Models/NavigationPathManager.swift",
                "Features/Posts", "Features/Profile", "Features/Search",
                "Features/Timeline/FeedVisibilityModifier.swift", "Features/Timeline/TimelineContentView.swift", "Features/Timeline/TimelineFeedView.swift", "Features/Timeline/FeedErrorView.swift", "Features/Timeline/TimelineFooterView.swift", "Features/Timeline/TimelineRowView.swift"
            ],
            sources: ["Models", "Services", "Utils", "Features/Timeline/TimelineStore.swift", "Features/Timeline/SeenPostStore.swift"]
        ),
        .testTarget(name: "BirdieCoreTests", dependencies: ["BirdieCore"], path: "Tests/BirdieCoreTests")
    ]
)
