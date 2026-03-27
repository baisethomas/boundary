//
//  RuleEngineTests.swift
//  BoundaryTests
//

import Foundation
import Testing
@testable import Boundary

@Suite("RuleEngine") struct RuleEngineTests {
    private let engine = RuleEngine()
    private let utc = RuleEngineSampleScenarios.utcCalendar

    @Test @MainActor func afterHours_activeWeeknightEvening() {
        let rule = PersistedRule(title: "After Hours", preset: .afterHours)

        let now = RuleEngineSampleScenarios.afterHoursActiveWednesdayEvening
        let result = engine.evaluate(
            rules: [rule],
            now: now,
            calendarEvents: [],
            isGloballyPaused: false,
            calendar: utc
        )

        #expect(result.boundaryState == .active(ruleId: rule.id))
        #expect(result.skippedRules.isEmpty)
        #expect(result.nextBoundarySummary == nil)
    }

    @Test @MainActor func afterHours_inactiveWeekdayAfternoon() {
        let rule = PersistedRule(title: "After Hours", preset: .afterHours)

        let now = RuleEngineSampleScenarios.afterHoursInactiveWednesdayAfternoon
        let result = engine.evaluate(
            rules: [rule],
            now: now,
            calendarEvents: [],
            isGloballyPaused: false,
            calendar: utc
        )

        #expect(result.boundaryState == .inactive)
        #expect(result.nextTriggerDate != nil)
    }

    @Test @MainActor func outOfOffice_activeWhenCalendarMatches() {
        let rule = PersistedRule(title: "OOO", preset: .outOfOffice)

        let now = RuleEngineSampleScenarios.outOfOfficeNow
        let start = utc.date(byAdding: .hour, value: -1, to: now)!
        let end = utc.date(byAdding: .hour, value: 2, to: now)!
        let event = RuleEngineSampleScenarios.outOfOfficeEvent(start: start, end: end)

        let result = engine.evaluate(
            rules: [rule],
            now: now,
            calendarEvents: [event],
            isGloballyPaused: false,
            calendar: utc
        )

        #expect(result.boundaryState == .active(ruleId: rule.id))
    }

    @Test @MainActor func deepWork_hybridRequiresScheduleAndEvent() {
        let rule = PersistedRule(title: "Deep Work", preset: .deepWork)

        let now = RuleEngineSampleScenarios.deepWorkWednesdayDuringWorkHours
        let start = utc.date(byAdding: .hour, value: -1, to: now)!
        let end = utc.date(byAdding: .hour, value: 2, to: now)!
        let event = RuleEngineSampleScenarios.focusBlockEvent(start: start, end: end)

        let withEvent = engine.evaluate(
            rules: [rule],
            now: now,
            calendarEvents: [event],
            isGloballyPaused: false,
            calendar: utc
        )
        #expect(withEvent.boundaryState == .active(ruleId: rule.id))

        let noEvent = engine.evaluate(
            rules: [rule],
            now: now,
            calendarEvents: [],
            isGloballyPaused: false,
            calendar: utc
        )
        #expect(noEvent.boundaryState == .inactive)
    }

    @Test @MainActor func calendarRuleWinsOverScheduleWhenBothMatch() {
        let older = Date(timeIntervalSince1970: 100)
        let newer = Date(timeIntervalSince1970: 200)

        let ooo = PersistedRule(
            title: "Out of Office",
            preset: .outOfOffice,
            createdAt: older
        )
        let afterHours = PersistedRule(
            title: "After Hours",
            preset: .afterHours,
            createdAt: newer
        )

        // Evening: after-hours schedule is active and OOO calendar event overlaps.
        let now = RuleEngineSampleScenarios.afterHoursActiveWednesdayEvening
        let start = utc.date(byAdding: .hour, value: -1, to: now)!
        let end = utc.date(byAdding: .hour, value: 3, to: now)!
        let event = RuleEngineSampleScenarios.outOfOfficeEvent(start: start, end: end)

        let result = engine.evaluate(
            rules: [afterHours, ooo],
            now: now,
            calendarEvents: [event],
            isGloballyPaused: false,
            calendar: utc
        )

        #expect(result.boundaryState == .active(ruleId: ooo.id))
        #expect(result.activeRuleTitle == "Out of Office")
    }

    @Test @MainActor func pausedShortCircuits() {
        let rule = PersistedRule(title: "After Hours", preset: .afterHours)

        let now = RuleEngineSampleScenarios.afterHoursActiveWednesdayEvening
        let result = engine.evaluate(
            rules: [rule],
            now: now,
            calendarEvents: [],
            isGloballyPaused: true,
            calendar: utc
        )

        #expect(result.boundaryState == .paused)
        #expect(result.skippedRules.isEmpty)
    }

    @Test func helpers_scheduleAndCalendar() {
        let schedule = QuietPreset.defaultTrigger(for: .afterHours).scheduleValue!
        let wednesday = RuleEngineSampleScenarios.afterHoursActiveWednesdayEvening
        #expect(RuleEngineHelpers.isScheduleActive(schedule, now: wednesday, calendar: utc))

        let cal = CalendarTrigger(
            keywords: ["Focus"],
            matchType: .keywordPartial,
            allowedEventTypes: [.focus]
        )
        let event = CalendarEventSummary(
            title: "Focus time",
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 10_000),
            eventType: .focus
        )
        let mid = Date(timeIntervalSince1970: 5_000)
        #expect(RuleEngineHelpers.calendarMatches(cal, event: event))
        #expect(!RuleEngineHelpers.matchingCalendarEvents(now: mid, trigger: cal, events: [event]).isEmpty)
    }
}

private extension RuleTrigger {
    var scheduleValue: ScheduleTrigger? {
        switch self {
        case let .schedule(s): s
        case let .hybrid(s, _): s
        case .calendar: nil
        }
    }
}
