// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription;

let package = Package(
    name: "Kitura-MiniHandlebars",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Kitura-MiniHandlebars",
            targets: ["Kitura-MiniHandlebars"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/IBM-Swift/Kitura-TemplateEngine.git", .upToNextMinor(from: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Kitura-MiniHandlebars",
            dependencies: ["KituraTemplateEngine"]),
        .testTarget(
            name: "Kitura-MiniHandlebarsTests",
            dependencies: ["Kitura-MiniHandlebars"]),
    ]
)
