//
//  Copyright © 2026 ObjectBox Ltd. All rights reserved.
//

import Foundation
import ObjectBox
import ObjectBoxMeshSync

/// Exercises the mesh sync API of the Swift package (Sync variant plus the ObjectBoxMeshSync product behind the
/// MeshSync trait) without starting anything: no radios, no Local Network or Bluetooth prompts, no peers.
enum MeshSyncSetup {
    static let meshId = "io.objectbox.inttest.macos.meshsync"

    /// Creates a store and a sync client with a Nearby mesh attached; the client is not started.
    static func makeClient(directory: URL) throws -> (Store, SyncClient) {
        let store = try Store(directoryPath: directory.path)
        // The server URL is unreachable on purpose; the client is never started anyway
        let configuration = Sync.Configuration(store: store, url: "ws://127.0.0.1:1")
        configuration.credentials = [SyncCredentials.makeNone()]
        let meshConfig = try AppleMeshSync.createConfig(meshId: meshId)
        meshConfig.nearbyMediums = [.wifiLAN]  // Optional, Nearby-specific setting provided by the add-on
        configuration.mesh = meshConfig
        let client = try Sync.makeClient(configuration: configuration)
        return (store, client)
    }
}
