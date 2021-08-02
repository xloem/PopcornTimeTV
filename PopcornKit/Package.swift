// swift-tools-version:5.4.0
import PackageDescription

let package = Package(
    name: "PopcornKit",
    platforms: [
        .iOS(.v12), .tvOS(.v12), .macOS(.v11)
    ],
    products: [
        .library(name: "PopcornKit", targets: ["PopcornKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.1"),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper", from: "4.2.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "4.9.0")
    ],
    targets: [
        .target(
            name: "PopcornKit",
            dependencies: ["SwiftyJSON", "ObjectMapper", "Alamofire"],
            path: "Sources"
        )
    ]
)
