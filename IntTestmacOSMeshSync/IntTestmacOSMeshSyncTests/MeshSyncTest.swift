//
//  Copyright © 2026 ObjectBox Ltd. All rights reserved.
//

import ObjectBox
import ObjectBoxMeshSync
import XCTest
@testable import IntTestmacOSMeshSync

/// Radio-free: proves the package wiring (trait, products, generated entity code, mesh API) on a consumer.
/// Functional mesh tests need two devices and permissions; they live in the objectbox-swift repository.
final class MeshSyncTest: XCTestCase {
    func testCreateClientWithMesh() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("obx-inttest-meshsync-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let (store, client) = try MeshSyncSetup.makeClient(directory: directory)
        defer {
            client.close()
            store.close()
        }
        let mesh = try XCTUnwrap(client.mesh)
        XCTAssertEqual(mesh.state, .created)  // Not started: nothing touches the network
        XCTAssertEqual(mesh.connectedPeerCount, 0)
    }

    func testNearbyMediumsSetting() throws {
        let meshConfig = try AppleMeshSync.createConfig(meshId: MeshSyncSetup.meshId)
        XCTAssertNil(meshConfig.nearbyMediums)  // Default: no restriction
        meshConfig.nearbyMediums = [.wifiLAN]
        XCTAssertEqual(meshConfig.nearbyMediums, [.wifiLAN])
    }
}
