// swift-tools-version:5.8

import Foundation
import PackageDescription

let packageURL: String
if let envURL = ProcessInfo.processInfo.environment["OBX_SPM_PACKAGE_REPO"] {
  packageURL = envURL
} else {
  packageURL = "https://github.com/objectbox/objectbox-swift-spm"
}
let packageBranch: String
if let envURL = ProcessInfo.processInfo.environment["OBX_SPM_PACKAGE_BRANCH"] {
  packageBranch = envURL
} else {
  packageBranch = "main"
}

let package = Package(
  name: "AnObjectBoxIntegrationTest",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v12)
  ],
  dependencies: [
    .package(url: packageURL, branch: packageBranch)
  ],
  targets: [
    .target(
      name: "${PROJECT_DIR}",
      dependencies: [
        .product(name: "ObjectBox.xcframework", package: "objectbox-swift-spm")
      ],
      path: "./${PROJECT_DIR}",
      // TODO can we remove this somehow (e.g. do we need a full Xcode project)?
      //      Also, it depends if the project is iOS or macOS
      exclude: [
        "AppDelegate.swift",
        "Assets.xcassets",
        "Info.plist",
        // "ObjectBox-models.json",  // Only present in non-clean state (generated in a previous run)
        "ViewController.swift",
      ]
    )
  ]
)
