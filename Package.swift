// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "jinengwuziqi",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "jinengwuziqi",
            targets: ["jinengwuziqi"]),
        .executable(
            name: "GomokuApp",
            targets: ["jinengwuziqi"]),
    ],
    targets: [
        .target(
            name: "jinengwuziqi"),
        .testTarget(
            name: "jinengwuziqiTests",
            dependencies: ["jinengwuziqi"]),
    ]
)
