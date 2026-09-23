// swift-tools-version: 6.0
import PackageDescription

// One target, four folders. Nothing in the build knows that `Domain/`,
// `Persistence/` and `Presentation/` are meant to be layers — that is the point.
let package = Package(
    name: "Checkout",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/x-sheep/swift-property-based.git", from: "1.2.0")
    ],
    targets: [
        .executableTarget(name: "Checkout"),
        .testTarget(
            name: "CheckoutTests",
            dependencies: [
                "Checkout",
                .product(name: "PropertyBased", package: "swift-property-based")
            ]
        )
    ]
)
