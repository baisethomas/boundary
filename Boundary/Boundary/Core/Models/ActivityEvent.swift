//
//  ActivityEvent.swift
//  Boundary
//
//  PRD ActivityItem — types and optional rule reference.
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
    /// Optional link to the rule that caused this entry.
    var ruleID: UUID? = nil

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        occurredAt: Date = .now,
        kind: ActivityKind = .skipped,
        ruleID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.occurredAt = occurredAt
        self.kindRaw = kind.rawValue
        self.ruleID = ruleID
    }

    var kind: ActivityKind {
        get { ActivityKind(rawValue: kindRaw) ?? .skipped }
        set { kindRaw = newValue.rawValue }
    }
}

enum ActivityKind: String, Codable, CaseIterable {
    case activated
    case ended
    case skipped
    case override
}
