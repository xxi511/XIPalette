// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "XIPalette",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "XIPalette", targets: ["XIPalette"])
    ],
    targets: [
        .target(
            name: "XIPalette",
            path: "Sources"
        )
    ]
)
