//
//  RuleEngine.swift
//  Boundary
//
//  Deterministic evaluation: calendar-only → hybrid (schedule ∧ calendar) → schedule-only.
//

import Foundation

protocol RuleEvaluating: AnyObject {
    func evaluate(
        rules: [PersistedRule],
        now: Date,
        calendarEvents: [CalendarEventSummary],
        isGloballyPaused: Bool,
        calendar: Calendar
    ) -> RuleEvaluationResult
}

extension RuleEvaluating {
    func evaluate(
        rules: [PersistedRule],
        now: Date,
        calendarEvents: [CalendarEventSummary],
        isGloballyPaused: Bool
    ) -> RuleEvaluationResult {
        evaluate(
            rules: rules,
            now: now,
            calendarEvents: calendarEvents,
            isGloballyPaused: isGloballyPaused,
            calendar: .current
        )
    }
}

/// Stateless, pure evaluation (thread-safe as long as `PersistedRule` snapshots are not mutated during the call).
final class RuleEngine: RuleEvaluating {

    func evaluate(
        rules: [PersistedRule],
        now: Date,
        calendarEvents: [CalendarEventSummary],
        isGloballyPaused: Bool,
        calendar: Calendar
    ) -> RuleEvaluationResult {
        if isGloballyPaused {
            return RuleEvaluationResult(
                boundaryState: .paused,
                activeRuleId: nil,
                activeRuleTitle: nil,
                reason: "Boundary is paused — rules are not evaluated until you resume.",
                nextTriggerDate: nil,
                evaluatedAt: now,
                nextBoundarySummary: nil,
                skippedRules: []
            )
        }

        let enabled = rules.filter(\.isEnabled).sorted { $0.createdAt < $1.createdAt }

        if enabled.isEmpty {
            return RuleEvaluationResult(
                boundaryState: .inactive,
                activeRuleId: nil,
                activeRuleTitle: nil,
                reason: "No enabled rules — add or enable a rule to automate quiet time.",
                nextTriggerDate: nil,
                evaluatedAt: now,
                nextBoundarySummary: nil,
                skippedRules: []
            )
        }

        let winner = resolveActiveRule(
            enabled: enabled,
            now: now,
            events: calendarEvents,
            calendar: calendar
        )

        if let winner {
            let endDate = deactivationDate(
                rule: winner,
                now: now,
                events: calendarEvents,
                calendar: calendar
            )
            let skipped = buildSkippedRules(
                enabled: enabled,
                winner: winner,
                now: now,
                events: calendarEvents,
                calendar: calendar
            )
            return RuleEvaluationResult(
                boundaryState: .active(ruleId: winner.id),
                activeRuleId: winner.id,
                activeRuleTitle: winner.title,
                reason: activationReason(for: winner, now: now, events: calendarEvents, calendar: calendar),
                nextTriggerDate: endDate,
                evaluatedAt: now,
                nextBoundarySummary: nil,
                skippedRules: skipped
            )
        }

        let nextStart = nextActivationDate(
            enabled: enabled,
            now: now,
            events: calendarEvents,
            calendar: calendar
        )
        let skipped = buildSkippedRules(
            enabled: enabled,
            winner: nil,
            now: now,
            events: calendarEvents,
            calendar: calendar
        )

        return RuleEvaluationResult(
            boundaryState: .inactive,
            activeRuleId: nil,
            activeRuleTitle: nil,
            reason: "No rule matches right now — calendar signals and time windows are both quiet.",
            nextTriggerDate: nextStart,
            evaluatedAt: now,
            nextBoundarySummary: formatNextSummary(date: nextStart),
            skippedRules: skipped
        )
    }

    // MARK: - Resolve active rule (priority)

    private func resolveActiveRule(
        enabled: [PersistedRule],
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> PersistedRule? {
        for rule in enabled {
            if case let .calendar(cal) = rule.trigger {
                if !RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events).isEmpty {
                    return rule
                }
            }
        }

        for rule in enabled {
            if case let .hybrid(schedule, cal) = rule.trigger {
                let scheduleOK = RuleEngineHelpers.isScheduleActive(schedule, now: now, calendar: calendar)
                let calendarOK = !RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events).isEmpty
                if scheduleOK && calendarOK {
                    return rule
                }
            }
        }

        for rule in enabled {
            if case let .schedule(schedule) = rule.trigger {
                if RuleEngineHelpers.isScheduleActive(schedule, now: now, calendar: calendar) {
                    return rule
                }
            }
        }

        return nil
    }

    // MARK: - Reasons & deactivation

    private func activationReason(
        for rule: PersistedRule,
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> String {
        switch rule.trigger {
        case let .calendar(cal):
            let titles = RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events).map(\.title)
            let sample = titles.first.map { "“\($0)”" } ?? "a matching event"
            return "Calendar rule — \(sample) matches keywords for «\(rule.title)»."
        case let .hybrid(schedule, cal):
            let titles = RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events).map(\.title)
            let sample = titles.first.map { "“\($0)”" } ?? "a matching event"
            let window = windowLabel(schedule: schedule)
            return "Hybrid rule — inside \(window) and \(sample) matches «\(rule.title)» calendar keywords."
        case let .schedule(schedule):
            return "Time-based rule — «\(rule.title)» is inside \(windowLabel(schedule: schedule))."
        }
    }

    private func windowLabel(schedule: ScheduleTrigger) -> String {
        let days = schedule.weekdays.map(\.shortSymbol).joined(separator: ", ")
        return "\(days) · \(formatTime(schedule.start))–\(formatTime(schedule.end))"
    }

    private func formatTime(_ t: SimpleTime) -> String {
        String(format: "%d:%02d", t.hour, t.minute)
    }

    private func deactivationDate(
        rule: PersistedRule,
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> Date? {
        switch rule.trigger {
        case let .calendar(cal):
            let matches = RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events)
            return matches.map(\.end).max()

        case let .hybrid(schedule, cal):
            let sEnd = RuleEngineHelpers.scheduleDeactivationDate(schedule: schedule, now: now, calendar: calendar)
            let matches = RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events)
            let cEnd = matches.map(\.end).max()
            switch (sEnd, cEnd) {
            case let (a?, b?):
                return min(a, b)
            case let (a?, nil):
                return a
            case let (nil, b?):
                return b
            default:
                return nil
            }

        case let .schedule(schedule):
            return RuleEngineHelpers.scheduleDeactivationDate(schedule: schedule, now: now, calendar: calendar)
        }
    }

    // MARK: - Next activation (inactive)

    private func nextActivationDate(
        enabled: [PersistedRule],
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> Date? {
        var candidates: [Date] = []

        for rule in enabled {
            switch rule.trigger {
            case let .schedule(schedule):
                if let d = RuleEngineHelpers.nextScheduleActivation(
                    schedule: schedule,
                    after: now,
                    calendar: calendar
                ) {
                    candidates.append(d)
                }

            case let .calendar(cal):
                if let d = RuleEngineHelpers.nextCalendarMatchStart(trigger: cal, after: now, events: events) {
                    candidates.append(d)
                }

            case let .hybrid(schedule, cal):
                if let d = RuleEngineHelpers.nextScheduleActivation(
                    schedule: schedule,
                    after: now,
                    calendar: calendar
                ) {
                    candidates.append(d)
                }
                for event in events where event.start > now {
                    guard RuleEngineHelpers.calendarMatches(cal, event: event) else { continue }
                    if RuleEngineHelpers.isScheduleActive(schedule, now: event.start, calendar: calendar) {
                        candidates.append(event.start)
                    }
                }
            }
        }

        return candidates.min()
    }

    private func formatNextSummary(date: Date?) -> String? {
        guard let date else { return nil }
        return "Next activation around \(date.formatted(date: .abbreviated, time: .shortened))."
    }

    // MARK: - Skipped rules

    private func buildSkippedRules(
        enabled: [PersistedRule],
        winner: PersistedRule?,
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> [SkippedRuleEvaluation] {
        enabled.compactMap { rule in
            if let winner, rule.id == winner.id { return nil }
            let reason = skipReason(
                rule: rule,
                winner: winner,
                now: now,
                events: events,
                calendar: calendar
            )
            return SkippedRuleEvaluation(ruleId: rule.id, ruleTitle: rule.title, reason: reason)
        }
    }

    private func skipReason(
        rule: PersistedRule,
        winner: PersistedRule?,
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> String {
        let satisfied = ruleSemanticallyMatches(rule: rule, now: now, events: events, calendar: calendar)
        if let winner, satisfied {
            return "Conditions match, but «\(winner.title)» has higher priority (calendar → hybrid → schedule)."
        }
        return triggerFailureReason(rule: rule, now: now, events: events, calendar: calendar)
    }

    private func ruleSemanticallyMatches(
        rule: PersistedRule,
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> Bool {
        switch rule.trigger {
        case let .calendar(cal):
            !RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events).isEmpty
        case let .schedule(schedule):
            RuleEngineHelpers.isScheduleActive(schedule, now: now, calendar: calendar)
        case let .hybrid(schedule, cal):
            RuleEngineHelpers.isScheduleActive(schedule, now: now, calendar: calendar)
                && !RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events).isEmpty
        }
    }

    private func triggerFailureReason(
        rule: PersistedRule,
        now: Date,
        events: [CalendarEventSummary],
        calendar: Calendar
    ) -> String {
        switch rule.trigger {
        case let .calendar(cal):
            let overlaps = events.filter { now >= $0.start && now <= $0.end }
            if overlaps.isEmpty {
                return "No calendar event overlaps the current time."
            }
            return "Calendar events are present, but none match keywords or allowed types for «\(rule.title)»."

        case let .schedule(schedule):
            let weekday = calendar.component(.weekday, from: now)
            if !RuleEngineHelpers.isWeekdayAllowed(weekday, schedule: schedule) {
                return "Today is outside this rule’s weekdays."
            }
            return "Inside the weekday, but outside the configured time window."

        case let .hybrid(schedule, cal):
            let scheduleOK = RuleEngineHelpers.isScheduleActive(schedule, now: now, calendar: calendar)
            let calendarOK = !RuleEngineHelpers.matchingCalendarEvents(now: now, trigger: cal, events: events).isEmpty
            switch (scheduleOK, calendarOK) {
            case (false, false):
                return "Hybrid needs both the schedule window and a matching calendar event — neither is true."
            case (true, false):
                return "Hybrid — schedule window is active, but no calendar event matches the keywords."
            case (false, true):
                return "Hybrid — a matching calendar event is active, but the schedule window is closed."
            case (true, true):
                return "Hybrid — both schedule and calendar match; another rule took priority."
            }
        }
    }
}
