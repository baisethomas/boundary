//
//  ActivityItem.swift
//  Boundary
//
//  PRD §7 — log entry (value type; SwiftData rows can map to/from this).
//

import Foundation

struct ActivityItem: Codable, Equatable, Hashable, Identifiable, Sendable {
    var id: UUID
    var timestamp: Date
    var type: ActivityType
    var ruleID: UUID?
    var title: String
    var detail: String

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        type: ActivityType,
        ruleID: UUID? = nil,
        title: String,
        detail: String = ""
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.ruleID = ruleID
        self.title = title
        self.detail = detail
    }
}
