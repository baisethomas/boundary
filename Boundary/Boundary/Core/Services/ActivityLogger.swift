//
//  ActivityLogger.swift
//  Boundary
//

import Foundation

protocol ActivityLogging: AnyObject {
    func record(
        title: String,
        detail: String,
        activityType: ActivityType,
        ruleID: UUID?,
        at date: Date,
        in store: ActivityStore
    )
}

@MainActor
final class ActivityLogger: ActivityLogging {
    func record(
        title: String,
        detail: String,
        activityType: ActivityType,
        ruleID: UUID? = nil,
        at date: Date = .now,
        in store: ActivityStore
    ) {
        try? store.append(title: title, detail: detail, activityType: activityType, ruleID: ruleID, at: date)
    }
}
