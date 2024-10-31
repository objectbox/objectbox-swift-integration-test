// swift-tools-version:5.9
import PackageDescription
import Foundation

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
    name: "YourPackageName",
    defaultLocalization: "en", // Set the default localization
    platforms: [
         .macOS(.v12)
    ],
    dependencies: [
        .package(url: packageURL, branch: packageBranch)
    ],
    targets: [
        .target(
            name: "IntTestiOSRegular",
            dependencies: [
                .product(name: "ObjectBox.xcframework", package: "objectbox-swift-spm")
            ],
            path: "./IntTestiOSRegular",
            exclude: [
                "AppDelegate.swift",
                "ViewController.swift",
                "Assets.xcassets",
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "IntTestiOSRegularTest",
            dependencies: ["IntTestiOSRegular"],
            path: "./IntTestiOSRegularTests"
        )
    ]
)
