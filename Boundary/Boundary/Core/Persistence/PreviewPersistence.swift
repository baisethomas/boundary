//
//  PreviewPersistence.swift
//  Boundary
//
//  Shared in-memory SwiftData container for SwiftUI previews (same schema as production).
//

import SwiftData

enum PreviewPersistence {
    static func inMemoryContainer() -> ModelContainer {
        do {
            return try BoundaryPersistence.makeInMemoryContainer()
        } catch {
            preconditionFailure("PreviewPersistence: \(error)")
        }
    }
}
