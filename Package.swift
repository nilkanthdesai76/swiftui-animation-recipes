// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swiftui-animation-recipes",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftUIAnimationRecipes",
            targets: ["SwiftUIAnimationRecipes"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftUIAnimationRecipes",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftUIAnimationRecipesTests",
            dependencies: ["SwiftUIAnimationRecipes"]
        ),
    ]
)
