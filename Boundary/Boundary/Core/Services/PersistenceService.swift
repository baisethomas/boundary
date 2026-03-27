//
//  PersistenceService.swift
//  Boundary
//
//  App entry uses `BoundaryPersistence` for disk URL + schema; this service handles
//  bootstrap helpers (singleton config) and explicit saves. All user data is SwiftData-only.
//

import SwiftData
import SwiftUI

protocol PersistenceServicing: AnyObject {
    func ensureSingletonConfiguration(in context: ModelContext)
    func save(_ context: ModelContext) throws
}

@MainActor
final class SwiftDataPersistenceService: PersistenceServicing {
    static let shared = SwiftDataPersistenceService()

    /// Single shared on-disk container for the app process (see `BoundaryApp` init).
    static func makeModelContainer() -> ModelContainer {
        do {
            return try BoundaryPersistence.makePersistentContainer()
        } catch {
            fatalError("Boundary could not open local store: \(error)")
        }
    }

    /// Tests and tools that must not touch the real database file.
    static func makeInMemoryModelContainer() throws -> ModelContainer {
        try BoundaryPersistence.makeInMemoryContainer()
    }

    func ensureSingletonConfiguration(in context: ModelContext) {
        // Must match `AppConfiguration.singletonID` (string literal required for #Predicate).
        var descriptor = FetchDescriptor<AppConfiguration>(
            predicate: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" }
        )
        descriptor.fetchLimit = 1
        if (try? context.fetch(descriptor).first) != nil {
            return
        }
        context.insert(AppConfiguration())
        try? context.save()
    }

    func save(_ context: ModelContext) throws {
        try context.save()
    }
}
