// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
// API reference: https://developer.apple.com/documentation/packagedescription/package

import PackageDescription

let package = Package(
  name: "AnObjectBoxIntegrationTest",
  defaultLocalization: "en",
  platforms: [
    // This should match the requirements of ObjectBox.xcframework (so the ObjectBox Swift API and native libraries)
    .macOS(.v11), .iOS(.v15),
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
    )
  ]
)
