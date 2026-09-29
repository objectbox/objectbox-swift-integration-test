// swift-tools-version: 6.1
// Manifest for the mesh sync integration test project (used by test.sh with --swiftpm --sync --meshsync): the
// ObjectBoxMeshSync product of the ObjectBox Swift package sits behind its MeshSync package trait, which needs
// Swift tools 6.1 and the Sync variant. See docs/mesh-sync.md in the objectbox-swift repo.
// API reference: https://developer.apple.com/documentation/packagedescription/package
import PackageDescription

let package = Package(
  name: "AnObjectBoxMeshSyncIntegrationTest",
  defaultLocalization: "en",
  platforms: [
    // This should match the requirements of ObjectBox.xcframework (so the ObjectBox Swift API and native libraries)
    .macOS(.v12), .iOS(.v15),
  ],
  dependencies: [
    // The MeshSync trait enables the add-on's google/nearby dependency (it is not fetched without the trait)
    .package(path: "../obx-swift-package", traits: ["MeshSync"]),
  ],
  targets: [
    .target(
      name: "${PROJECT_DIR}",
      dependencies: [
        .product(name: "ObjectBox-Sync.xcframework", package: "obx-swift-package"),
        .product(name: "ObjectBoxMeshSync", package: "obx-swift-package"),
      ],
      path: "./${PROJECT_DIR}"
    ),
    .testTarget(
      name: "${PROJECT_DIR}Test",
      dependencies: ["${PROJECT_DIR}"],
      path: "./${PROJECT_DIR}Tests"
    ),
  ],
  // Tools 6.1 defaults to Swift 6 language mode, which the generated ObjectBox entity code is not clean for yet
  swiftLanguageModes: [.v5]
)
