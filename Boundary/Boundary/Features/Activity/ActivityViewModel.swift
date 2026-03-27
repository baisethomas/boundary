//
//  ActivityViewModel.swift
//  Boundary
//

import SwiftUI

@MainActor
@Observable
final class ActivityViewModel {
    private let activityLogger: any ActivityLogging

    /// Current timeline filter (drives empty vs. filtered-empty UI).
    var filter: ActivityFilter = .all

    init(activityLogger: any ActivityLogging) {
        self.activityLogger = activityLogger
    }

    func logSampleEvent(in store: ActivityStore) {
        activityLogger.record(
            title: "Manual check-in",
            detail: "Placeholder log entry",
            activityType: .skipped,
            ruleID: nil,
            at: .now,
            in: store
        )
    }

    func filteredActivities(from source: [ActivityItem]) -> [ActivityItem] {
        source.filter { filter.includes($0.type) }
    }

    /// Newest calendar days first; within each day, newest events first.
    func dayGroupedSections(from source: [ActivityItem]) -> [(day: Date, items: [ActivityItem])] {
        let filtered = filteredActivities(from: source)
        let cal = Calendar.current
        let byDay = Dictionary(grouping: filtered) { cal.startOfDay(for: $0.timestamp) }
        return byDay.keys.sorted(by: >).map { day in
            let items = (byDay[day] ?? []).sorted { $0.timestamp > $1.timestamp }
            return (day, items)
        }
    }

}
