//
//  BoundaryPersistence.swift
//  Boundary
//
//  Local-only persistence: one SwiftData store on disk under Application Support.
//  Models stay in Core/Models; this type only defines schema, file location, and containers.
//

import Foundation
import SwiftData

enum BoundaryPersistence {
    /// All persisted entities for the app target (single store file).
    static let schema = Schema([
        AppConfiguration.self,
        PersistedRule.self,
        ActivityEvent.self,
    ])

    private static let subdirectoryName = "Boundary"
    private static let storeFileName = "Boundary.store"

    /// Stable on-disk URL (survives relaunch; not synced to iCloud).
    static var persistentStoreURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directory = base.appendingPathComponent(subdirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
        )
        return directory.appendingPathComponent(storeFileName)
    }

    /// Production container: disk-backed, no CloudKit.
    static func makePersistentContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            url: persistentStoreURL,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Previews, tests, and canvas hosts (no files, no cross-test pollution).
    static func makeInMemoryContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
