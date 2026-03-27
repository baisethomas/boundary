//
//  MockData.swift
//  Boundary
//

import Foundation

/// Static samples for SwiftUI previews, tests, and seeding in-memory stores.
enum MockData {
    static let weekdaysWorkWeek: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]

    static let afterHoursSchedule = ScheduleTrigger(
        weekdays: weekdaysWorkWeek,
        start: SimpleTime(hour: 18),
        end: SimpleTime(hour: 8)
    )

    static let businessHoursSchedule = ScheduleTrigger(
        weekdays: weekdaysWorkWeek,
        start: SimpleTime(hour: 9),
        end: SimpleTime(hour: 17)
    )

    static let oooCalendarTrigger = CalendarTrigger(
        keywords: ["OOO", "Out of office", "Vacation"],
        matchType: .keywordPartial,
        allowedEventTypes: [.standard, .allDay, .outOfOffice]
    )

    static let focusCalendarTrigger = CalendarTrigger(
        keywords: ["Focus", "Deep work"],
        matchType: .keywordPartial,
        allowedEventTypes: [.standard, .focus]
    )

    static let quietDoNotDisturb = QuietModeProfile.baseline(for: .doNotDisturb, name: "Evening quiet")
    static let quietWork = QuietModeProfile.baseline(for: .work, name: "Work focus")

    static let sampleRuleAfterHours = BoundaryRule(
        name: "After hours",
        trigger: .schedule(afterHoursSchedule),
        quietMode: quietDoNotDisturb,
        restoreBehavior: .revertPrevious
    )

    static let sampleRuleOOO = BoundaryRule(
        name: "Out of office",
        trigger: .calendar(oooCalendarTrigger),
        quietMode: QuietModeProfile.baseline(for: .doNotDisturb, name: "OOO"),
        restoreBehavior: .default
    )

    static let sampleRuleDeepWork = BoundaryRule(
        name: "Deep work",
        trigger: .hybrid(schedule: businessHoursSchedule, calendar: focusCalendarTrigger),
        quietMode: quietWork,
        restoreBehavior: .maintain
    )

    static let sampleRules: [BoundaryRule] = [
        sampleRuleAfterHours,
        sampleRuleOOO,
        sampleRuleDeepWork,
    ]

    static let sampleActivityItems: [ActivityItem] = [
        ActivityItem(type: .activated, ruleID: sampleRuleAfterHours.id, title: "Boundary on", detail: "Schedule matched"),
        ActivityItem(type: .ended, ruleID: sampleRuleAfterHours.id, title: "Boundary off", detail: "Window ended"),
        ActivityItem(type: .paused, title: "Boundary paused", detail: "Rules on hold"),
        ActivityItem(type: .resumed, title: "Boundary resumed", detail: "Evaluating again"),
        ActivityItem(type: .override, title: "Manual override", detail: "User resumed notifications"),
        ActivityItem(type: .skipped, title: "Evaluation skipped", detail: "Calendar permission denied"),
    ]

    static let defaultAppSettings = AppSettings(onboardingComplete: true, isPaused: false)
    static let pausedAppSettings = AppSettings(onboardingComplete: true, isPaused: true)
}
