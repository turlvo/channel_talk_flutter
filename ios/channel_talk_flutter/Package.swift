// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "channel_talk_flutter",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(name: "channel-talk-flutter", targets: ["channel_talk_flutter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/channel-io/channel-talk-ios-framework", exact: "13.3.0"),
    ],
    targets: [
        .target(
            name: "channel_talk_flutter",
            dependencies: [
                .product(name: "ChannelIOSDK", package: "channel-talk-ios-framework"),
            ],
            path: "Sources/channel_talk_flutter",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
