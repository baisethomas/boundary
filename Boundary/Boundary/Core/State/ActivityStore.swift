//
//  ActivityStore.swift
//  Boundary
//
//  Activity history for UI; mock items until SwiftData hydrates.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class ActivityStore {
    private var modelContext: ModelContext?

    private(set) var activities: [ActivityItem] = MockData.sampleActivityItems

    var isPersistenceBound: Bool { modelContext != nil }

    func bind(_ context: ModelContext) {
        modelContext = context
        activities = []
        try? refreshFromPersistence()
    }

    private func requireContext() -> ModelContext {
        guard let modelContext else {
            fatalError("ActivityStore used before bind(modelContext:)")
        }
        return modelContext
    }

    func refreshFromPersistence() throws {
        guard modelContext != nil else { return }
        let context = requireContext()
        let descriptor = FetchDescriptor<ActivityEvent>(sortBy: [SortDescriptor(\.occurredAt, order: .reverse)])
        let rows = try context.fetch(descriptor)
        activities = rows.map(\.activityItem)
    }

    func append(
        title: String,
        detail: String,
        activityType: ActivityType,
        ruleID: UUID? = nil,
        at date: Date = .now
    ) throws {
        let context = requireContext()
        context.insert(ActivityEvent(title: title, detail: detail, occurredAt: date, activityType: activityType, ruleID: ruleID))
        try context.save()
        try refreshFromPersistence()
    }
}
