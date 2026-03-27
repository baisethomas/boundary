//
//  ActivityViewModel.swift
//  Boundary
//

import SwiftUI

@MainActor
@Observable
final class ActivityViewModel {
    private let activityLogger: any ActivityLogging

    init(activityLogger: any ActivityLogging) {
        self.activityLogger = activityLogger
    }

    func logSampleEvent(in store: ActivityStore) {
        activityLogger.record(
            title: "Manual check-in",
            detail: "Placeholder log entry",
            kind: .skipped,
            ruleID: nil,
            at: .now,
            in: store
        )
    }
}
