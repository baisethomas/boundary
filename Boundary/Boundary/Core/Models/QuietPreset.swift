//
//  QuietPreset.swift
//  Boundary
//

import Foundation

enum QuietPreset: String, CaseIterable, Codable, Identifiable {
    case afterHours
    case outOfOffice
    case deepWork

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .afterHours: "After Hours"
        case .outOfOffice: "Out of Office"
        case .deepWork: "Deep Work"
        }
    }

    var subtitle: String {
        switch self {
        case .afterHours: "Wind down notifications outside work hours."
        case .outOfOffice: "Full quiet while you are away."
        case .deepWork: "Minimal interruptions for focused blocks."
        }
    }

    /// Default PRD-style trigger until the rule builder exists.
    static func defaultTrigger(for preset: QuietPreset) -> RuleTrigger {
        switch preset {
        case .afterHours:
            .schedule(RuleTrigger.defaultAfterHoursSchedule())
        case .outOfOffice:
            .calendar(CalendarTrigger(keywords: ["OOO", "Out of office", "Vacation"]))
        case .deepWork:
            .hybrid(
                schedule: ScheduleTrigger(
                    weekdayIndices: [2, 3, 4, 5, 6],
                    startMinutesFromMidnight: 9 * 60,
                    endMinutesFromMidnight: 17 * 60
                ),
                calendar: CalendarTrigger(keywords: ["Focus", "Deep work"])
            )
        }
    }

    var defaultQuietMode: QuietMode {
        switch self {
        case .afterHours, .outOfOffice: .doNotDisturb
        case .deepWork: .work
        }
    }

    var defaultRestoreBehavior: RestoreBehavior {
        switch self {
        case .afterHours: .revertPrevious
        case .outOfOffice: .default
        case .deepWork: .maintain
        }
    }
}
