// swift-tools-version: 6.0
import PackageDescription

// One target, four folders. Nothing in the build knows that `Domain/`,
// `Persistence/` and `Presentation/` are meant to be layers — that is the point.
let package = Package(
    name: "Checkout",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Checkout")
    ]
)
