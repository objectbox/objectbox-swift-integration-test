// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "AnObjectBoxIntegrationTestWithTestTarget",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v12),
    .iOS(.v12)
  ],
  dependencies: [
    .package(path: "../obx-swift-package"),
  ],
  targets: [
    .target(
      name: "${PROJECT_DIR}",
      dependencies: [
        .product(name: "ObjectBox.xcframework", package: "obx-swift-package")
      ],
      path: "./${PROJECT_DIR}",
      // Currently test projects also include an Xcode project to test with CocoaPods,
      // so exclude (iOS/macOS UI) specific files that are not supported by Swift Package projects.
      exclude: [
        "AppDelegate.swift",
        "Assets.xcassets",
        "Info.plist",
        "ObxSwiftUiTestApp.swift",
        "ViewController.swift",
      ]
    ),
    .testTarget(
      name: "${PROJECT_DIR}Test",
      dependencies: ["${PROJECT_DIR}"],
      path: "./${PROJECT_DIR}Tests"
    ),
  ]
)
