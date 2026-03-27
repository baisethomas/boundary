//
//  QuietPreset.swift
//  Boundary
//

import Foundation

enum QuietPreset: String, CaseIterable, Codable, Identifiable {
    case afterHours
    case outOfOffice
    case deepWork
    case familyTime

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .afterHours: "After Hours"
        case .outOfOffice: "Out of Office"
        case .deepWork: "Deep Work"
        case .familyTime: "Family Time"
        }
    }

    var subtitle: String {
        switch self {
        case .afterHours: "Wind down notifications outside work hours."
        case .outOfOffice: "Full quiet while you are away."
        case .deepWork: "Minimal interruptions for focused blocks."
        case .familyTime: "Protect weekends and evenings for life outside work."
        }
    }

    var defaultQuietProfile: QuietModeProfile {
        switch self {
        case .afterHours:
            QuietModeProfile.baseline(for: .doNotDisturb, name: displayName)
        case .outOfOffice:
            QuietModeProfile.baseline(for: .doNotDisturb, name: displayName)
        case .deepWork:
            QuietModeProfile.baseline(for: .work, name: displayName)
        case .familyTime:
            QuietModeProfile.baseline(for: .personal, name: displayName)
        }
    }

    /// Default PRD-style trigger until the rule builder exists.
    static func defaultTrigger(for preset: QuietPreset) -> RuleTrigger {
        switch preset {
        case .afterHours:
            .schedule(RuleTrigger.defaultAfterHoursSchedule())
        case .outOfOffice:
            .calendar(
                CalendarTrigger(
                    keywords: ["OOO", "Out of office", "Vacation"],
                    matchType: .keywordPartial,
                    allowedEventTypes: [.standard, .allDay, .outOfOffice]
                )
            )
        case .deepWork:
            .hybrid(
                schedule: ScheduleTrigger(
                    weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday],
                    start: SimpleTime(hour: 9),
                    end: SimpleTime(hour: 17)
                ),
                calendar: CalendarTrigger(
                    keywords: ["Focus", "Deep work"],
                    matchType: .keywordPartial,
                    allowedEventTypes: [.standard, .focus]
                )
            )
        case .familyTime:
            .schedule(
                ScheduleTrigger(
                    weekdays: [.saturday, .sunday],
                    start: SimpleTime(hour: 8),
                    end: SimpleTime(hour: 21)
                )
            )
        }
    }

    var defaultRestoreBehavior: RestoreBehavior {
        switch self {
        case .afterHours: .revertPrevious
        case .outOfOffice: .default
        case .deepWork: .maintain
        case .familyTime: .revertPrevious
        }
    }

    /// Short copy for onboarding summary (not full rule-builder wording).
    var onboardingTriggerSummary: String {
        switch self {
        case .afterHours: "Weeknights outside typical work hours."
        case .outOfOffice: "When calendar events match out-of-office keywords."
        case .deepWork: "Work hours plus calendar events tagged for focus."
        case .familyTime: "Weekends from morning through evening."
        }
    }
}
