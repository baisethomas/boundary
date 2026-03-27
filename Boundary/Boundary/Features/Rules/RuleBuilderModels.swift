//
//  RuleBuilderModels.swift
//  Boundary
//

import Foundation

/// Linear wizard steps for the rule builder (easy to swap for a single scroll later).
enum RuleBuilderStep: Int, CaseIterable, Identifiable, Sendable {
    case basics = 0
    case trigger = 1
    case quiet = 2
    case review = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .basics: "Basics"
        case .trigger: "Trigger"
        case .quiet: "Quiet mode"
        case .review: "Review"
        }
    }
}

/// High-level trigger choice shown in the picker (maps to `RuleTrigger`).
enum RuleBuilderTriggerKind: String, CaseIterable, Identifiable, Sendable {
    case schedule
    case calendar
    case hybrid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .schedule: "Schedule"
        case .calendar: "Calendar event"
        case .hybrid: "Hybrid"
        }
    }

    var subtitle: String {
        switch self {
        case .schedule: "Quiet during chosen days and hours."
        case .calendar: "Quiet when event titles match your keywords."
        case .hybrid: "Requires both schedule window and a calendar match."
        }
    }
}

enum RuleBuilderKeywordSuggestions {
    static let calendar: [String] = ["OOO", "PTO", "Vacation", "Focus", "Deep Work"]
}
