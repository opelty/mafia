// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "assets-generator",
    platforms: [.iOS("16.0")],
    products: [
      .plugin(
        name: "assets-generator",
        targets: ["assets-generator"]
      ),
    ],
    targets: [
      .target(
        name: "Example",
        plugins: ["assets-generator"]
      ),
      .executableTarget(name: "AssetsCodegen"),
      .plugin(
        name: "assets-generator",
        capability: .buildTool(),
        dependencies: ["AssetsCodegen"]
      ),
    ]
)
