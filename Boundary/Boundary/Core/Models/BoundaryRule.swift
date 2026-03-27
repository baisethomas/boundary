//
//  BoundaryRule.swift
//  Boundary
//
//  PRD §7 — domain rule (mirror of persisted rule; encode as a blob or map field-by-field).
//

import Foundation

struct BoundaryRule: Codable, Equatable, Hashable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var isEnabled: Bool
    var trigger: RuleTrigger
    var quietMode: QuietModeProfile
    var restoreBehavior: RestoreBehavior
    var createdAt: Date
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        isEnabled: Bool = true,
        trigger: RuleTrigger,
        quietMode: QuietModeProfile,
        restoreBehavior: RestoreBehavior,
        createdAt: Date = .now,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.trigger = trigger
        self.quietMode = quietMode
        self.restoreBehavior = restoreBehavior
        self.createdAt = createdAt
        self.notes = notes
    }
}
