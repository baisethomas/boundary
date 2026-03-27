//
//  RuleEngineSampleScenarios.swift
//  Boundary
//
//  Documented, reproducible inputs for tests and manual verification (fixed UTC calendar).
//

import Foundation

/// Named scenarios matching MVP presets: After Hours, Out of Office, Deep Work (hybrid).
enum RuleEngineSampleScenarios {
    /// Gregorian calendar with a fixed UTC zone — use with `RuleEngine.evaluate(..., calendar:)`.
    static var utcCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }

    // MARK: - After Hours (schedule: Mon–Fri 18:00 → 08:00)

    /// Wednesday 15 Jan 2025, 20:00 UTC — weekday evening inside after-hours window.
    static var afterHoursActiveWednesdayEvening: Date {
        date(
            year: 2025, month: 1, day: 15, hour: 20, minute: 0,
            calendar: utcCalendar
        )
    }

    /// Wednesday 15 Jan 2025, 14:00 UTC — weekday afternoon outside after-hours window.
    static var afterHoursInactiveWednesdayAfternoon: Date {
        date(
            year: 2025, month: 1, day: 15, hour: 14, minute: 0,
            calendar: utcCalendar
        )
    }

    // MARK: - Out of Office (calendar keywords)

    /// Event overlapping `now` with OOO-style title (use with `outOfOfficeNow`).
    static func outOfOfficeEvent(
        title: String = "Out of office — back Monday",
        start: Date,
        end: Date
    ) -> CalendarEventSummary {
        CalendarEventSummary(title: title, start: start, end: end, eventType: .outOfOffice)
    }

    static var outOfOfficeNow: Date {
        date(year: 2025, month: 1, day: 15, hour: 12, minute: 0, calendar: utcCalendar)
    }

    // MARK: - Deep Work (hybrid: Mon–Fri 09:00–17:00 + focus keywords)

    static var deepWorkWednesdayDuringWorkHours: Date {
        date(year: 2025, month: 1, day: 15, hour: 14, minute: 0, calendar: utcCalendar)
    }

    static func focusBlockEvent(
        title: String = "Deep work block",
        start: Date,
        end: Date
    ) -> CalendarEventSummary {
        CalendarEventSummary(title: title, start: start, end: end, eventType: .focus)
    }

    private static func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        comps.nanosecond = 0
        return calendar.date(from: comps)!
    }
}
