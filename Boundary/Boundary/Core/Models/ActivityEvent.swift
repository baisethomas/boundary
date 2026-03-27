//
//  ActivityEvent.swift
//  Boundary
//
//  SwiftData row — mirrors `ActivityItem`.
//

import Foundation
import SwiftData

@Model
final class ActivityEvent {
    var id: UUID
    var title: String
    var detail: String
    var occurredAt: Date
    var kindRaw: String
    var ruleID: UUID? = nil

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        occurredAt: Date = .now,
        activityType: ActivityType = .skipped,
        ruleID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.occurredAt = occurredAt
        self.kindRaw = activityType.rawValue
        self.ruleID = ruleID
    }

    var activityType: ActivityType {
        get { ActivityType(rawValue: kindRaw) ?? .skipped }
        set { kindRaw = newValue.rawValue }
    }

    var activityItem: ActivityItem {
        get {
            ActivityItem(
                id: id,
                timestamp: occurredAt,
                type: activityType,
                ruleID: ruleID,
                title: title,
                detail: detail
            )
        }
        set {
            id = newValue.id
            occurredAt = newValue.timestamp
            activityType = newValue.type
            ruleID = newValue.ruleID
            title = newValue.title
            detail = newValue.detail
        }
    }
}
