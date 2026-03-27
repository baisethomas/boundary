//
//  ActivityStore.swift
//  Boundary
//
//  PRD Section 6 — activity log facade.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class ActivityStore {
    private var modelContext: ModelContext?

    func bind(_ context: ModelContext) {
        modelContext = context
    }

    private func requireContext() -> ModelContext {
        guard let modelContext else {
            fatalError("ActivityStore used before bind(modelContext:)")
        }
        return modelContext
    }

    func append(
        title: String,
        detail: String,
        kind: ActivityKind,
        ruleID: UUID? = nil,
        at date: Date = .now
    ) throws {
        let context = requireContext()
        context.insert(ActivityEvent(title: title, detail: detail, occurredAt: date, kind: kind, ruleID: ruleID))
        try context.save()
    }

    func fetchAll() throws -> [ActivityEvent] {
        var descriptor = FetchDescriptor<ActivityEvent>(sortBy: [SortDescriptor(\.occurredAt, order: .reverse)])
        return try requireContext().fetch(descriptor)
    }
}
