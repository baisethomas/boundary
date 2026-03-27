//
//  PersistenceService.swift
//  Boundary
//
//  PRD Section 6 — persistence bootstrap and save helpers.
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

    static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            AppConfiguration.self,
            PersistedRule.self,
            ActivityEvent.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    func ensureSingletonConfiguration(in context: ModelContext) {
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
