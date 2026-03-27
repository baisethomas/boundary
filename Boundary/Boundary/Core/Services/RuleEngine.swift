//
//  RuleEngine.swift
//  Boundary
//
//  PRD Sections 8–9 — evaluation order and outputs (stub logic, deterministic).
//

import Foundation

struct CalendarEventSummary: Equatable, Sendable {
    var title: String
    var start: Date
    var end: Date
}

struct RuleEvaluationResult: Sendable {
    var boundaryState: BoundaryState
    var activeRuleId: UUID?
    var activeRuleTitle: String?
    var reason: String
    var nextTriggerDate: Date?
    var evaluatedAt: Date
    /// Placeholder until next-trigger computation exists.
    var nextBoundarySummary: String?
}

protocol RuleEvaluating: AnyObject {
    func evaluate(
        rules: [PersistedRule],
        now: Date,
        calendarEvents: [CalendarEventSummary],
        isGloballyPaused: Bool
    ) -> RuleEvaluationResult
}

@MainActor
final class RuleEngine: RuleEvaluating {
    func evaluate(
        rules: [PersistedRule],
        now: Date,
        calendarEvents: [CalendarEventSummary],
        isGloballyPaused: Bool
    ) -> RuleEvaluationResult {
        if isGloballyPaused {
            return RuleEvaluationResult(
                boundaryState: .paused,
                activeRuleId: nil,
                activeRuleTitle: nil,
                reason: "Boundary is paused",
                nextTriggerDate: nil,
                evaluatedAt: now,
                nextBoundarySummary: nil
            )
        }

        let enabled = rules.filter(\.isEnabled)

        if let calendarMatch = firstCalendarMatch(rules: enabled, events: calendarEvents, now: now) {
            return RuleEvaluationResult(
                boundaryState: .active(ruleId: calendarMatch.id),
                activeRuleId: calendarMatch.id,
                activeRuleTitle: calendarMatch.title,
                reason: "Calendar keyword match (priority over schedule)",
                nextTriggerDate: nil,
                evaluatedAt: now,
                nextBoundarySummary: nil
            )
        }

        if let scheduleMatch = firstScheduleMatch(rules: enabled, now: now) {
            return RuleEvaluationResult(
                boundaryState: .active(ruleId: scheduleMatch.id),
                activeRuleId: scheduleMatch.id,
                activeRuleTitle: scheduleMatch.title,
                reason: "Schedule window",
                nextTriggerDate: nil,
                evaluatedAt: now,
                nextBoundarySummary: nil
            )
        }

        let nextTitle = enabled.first?.title
        return RuleEvaluationResult(
            boundaryState: .inactive,
            activeRuleId: nil,
            activeRuleTitle: nil,
            reason: enabled.isEmpty ? "No enabled rules" : "No matching trigger at this time",
            nextTriggerDate: nil,
            evaluatedAt: now,
            nextBoundarySummary: nextTitle.map { "Next: \($0) (mock)" }
        )
    }

    /// Stub: case-insensitive partial keyword match on event titles (PRD Section 9).
    private func firstCalendarMatch(rules: [PersistedRule], events: [CalendarEventSummary], now: Date) -> PersistedRule? {
        for rule in rules {
            switch rule.trigger {
            case let .calendar(cal):
                if matchesCalendarRule(cal, events: events, now: now) { return rule }
            case let .hybrid(_, cal):
                if matchesCalendarRule(cal, events: events, now: now) { return rule }
            case .schedule:
                continue
            }
        }
        return nil
    }

    private func matchesCalendarRule(_ trigger: CalendarTrigger, events: [CalendarEventSummary], now: Date) -> Bool {
        for event in events where now >= event.start && now <= event.end {
            let lowerTitle = event.title.lowercased()
            for keyword in trigger.keywords {
                if lowerTitle.contains(keyword.lowercased()) { return true }
            }
        }
        return false
    }

    /// Stub: schedule windows from `ScheduleTrigger` (supports overnight ranges).
    private func firstScheduleMatch(rules: [PersistedRule], now: Date) -> PersistedRule? {
        for rule in rules {
            switch rule.trigger {
            case let .schedule(schedule):
                if isScheduleActive(schedule, now: now) { return rule }
            case let .hybrid(schedule, _):
                if isScheduleActive(schedule, now: now) { return rule }
            case .calendar:
                continue
            }
        }
        return nil
    }

    private func isScheduleActive(_ schedule: ScheduleTrigger, now: Date) -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        let weekday = calendar.component(.weekday, from: now)
        guard schedule.weekdayIndices.contains(weekday) else { return false }

        let minutes = minutesFromMidnight(now, calendar: calendar)
        let start = schedule.startMinutesFromMidnight
        let end = schedule.endMinutesFromMidnight
        if start <= end {
            return minutes >= start && minutes < end
        }
        return minutes >= start || minutes < end
    }

    private func minutesFromMidnight(_ date: Date, calendar: Calendar) -> Int {
        let h = calendar.component(.hour, from: date)
        let m = calendar.component(.minute, from: date)
        return h * 60 + m
    }
}
