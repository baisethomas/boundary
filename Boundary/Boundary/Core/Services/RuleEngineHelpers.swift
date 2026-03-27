//
//  RuleEngineHelpers.swift
//  Boundary
//
//  Pure, testable helpers: weekday windows, calendar keyword matching, schedule boundaries.
//

import Foundation

enum RuleEngineHelpers {
    // MARK: - Calendar (Gregorian wall time)

    /// Prefer injecting the same `Calendar` in tests and production for deterministic results.
    static func evaluationCalendar(timeZone: TimeZone = .current) -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = timeZone
        return c
    }

    // MARK: - Weekday / schedule windows

    static func isWeekdayAllowed(_ weekdayIndex: Int, schedule: ScheduleTrigger) -> Bool {
        schedule.weekdayIndices.contains(weekdayIndex)
    }

    static func minutesFromMidnight(_ date: Date, calendar: Calendar) -> Int {
        let h = calendar.component(.hour, from: date)
        let m = calendar.component(.minute, from: date)
        return h * 60 + m
    }

    /// True when `now` falls in the schedule window (half-open on same-day ranges: `[start, end)`).
    static func isScheduleActive(_ schedule: ScheduleTrigger, now: Date, calendar: Calendar) -> Bool {
        let weekday = calendar.component(.weekday, from: now)
        guard isWeekdayAllowed(weekday, schedule: schedule) else { return false }

        let minutes = minutesFromMidnight(now, calendar: calendar)
        let start = schedule.startMinutesFromMidnight
        let end = schedule.endMinutesFromMidnight

        if start <= end {
            return minutes >= start && minutes < end
        }
        return minutes >= start || minutes < end
    }

    /// End of the **current** active schedule segment, if `now` is inside the window.
    static func scheduleDeactivationDate(schedule: ScheduleTrigger, now: Date, calendar: Calendar) -> Date? {
        guard isScheduleActive(schedule, now: now, calendar: calendar) else { return nil }

        let dayStart = calendar.startOfDay(for: now)
        let minutes = minutesFromMidnight(now, calendar: calendar)
        let startM = schedule.startMinutesFromMidnight
        let endM = schedule.endMinutesFromMidnight

        if startM <= endM {
            return time(on: dayStart, simple: schedule.end, calendar: calendar)
        }

        if minutes >= startM {
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return nil }
            return time(on: nextDay, simple: schedule.end, calendar: calendar)
        }

        return time(on: dayStart, simple: schedule.end, calendar: calendar)
    }

    /// Earliest `Date` strictly after `now` when this schedule window **opens** (bounded search).
    static func nextScheduleActivation(
        schedule: ScheduleTrigger,
        after now: Date,
        calendar: Calendar,
        lookaheadDays: Int = 14
    ) -> Date? {
        var best: Date?
        let startOfToday = calendar.startOfDay(for: now)
        let startM = schedule.startMinutesFromMidnight
        let endM = schedule.endMinutesFromMidnight

        for dayOffset in 0..<lookaheadDays {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfToday) else { continue }
            let weekday = calendar.component(.weekday, from: day)
            guard schedule.weekdayIndices.contains(weekday) else { continue }

            if startM <= endM {
                guard let open = time(on: day, simple: schedule.start, calendar: calendar), open > now else { continue }
                if best == nil || open < best! { best = open }
            } else {
                guard let open = time(on: day, simple: schedule.start, calendar: calendar), open > now else { continue }
                if best == nil || open < best! { best = open }
            }
        }
        return best
    }

    private static func time(on dayStart: Date, simple: SimpleTime, calendar: Calendar) -> Date? {
        calendar.date(bySettingHour: simple.hour, minute: simple.minute, second: 0, of: dayStart)
    }

    // MARK: - Calendar triggers

    static func calendarMatches(_ trigger: CalendarTrigger, event: CalendarEventSummary) -> Bool {
        guard trigger.allowedEventTypes.contains(event.eventType) else { return false }
        return trigger.matches(eventTitle: event.title)
    }

    /// Events overlapping `now` that satisfy the calendar trigger.
    static func matchingCalendarEvents(
        now: Date,
        trigger: CalendarTrigger,
        events: [CalendarEventSummary]
    ) -> [CalendarEventSummary] {
        events.filter { event in
            now >= event.start && now <= event.end && calendarMatches(trigger, event: event)
        }
    }

    /// Future event starts (strictly after `now`) that would match a calendar-only trigger.
    static func nextCalendarMatchStart(
        trigger: CalendarTrigger,
        after now: Date,
        events: [CalendarEventSummary]
    ) -> Date? {
        events
            .filter { $0.start > now && calendarMatches(trigger, event: $0) }
            .map(\.start)
            .min()
    }
}
