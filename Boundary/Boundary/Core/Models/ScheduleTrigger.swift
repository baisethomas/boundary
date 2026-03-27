//
//  ScheduleTrigger.swift
//  Boundary
//
//  PRD §9 — days of week + start/end time.
//

import Foundation

struct ScheduleTrigger: Codable, Equatable, Hashable, Sendable {
    var weekdays: [Weekday]
    var start: SimpleTime
    var end: SimpleTime

    init(weekdays: [Weekday], start: SimpleTime, end: SimpleTime) {
        self.weekdays = weekdays.uniquedWeekdays()
        self.start = start
        self.end = end
    }

    /// Sorted weekday indices for `Calendar.Component.weekday` (1…7).
    var weekdayIndices: [Int] {
        weekdays.map(\.gregorianIndex).sorted()
    }

    var startMinutesFromMidnight: Int { start.minutesFromMidnight }
    var endMinutesFromMidnight: Int { end.minutesFromMidnight }
}

private extension [Weekday] {
    func uniquedWeekdays() -> [Weekday] {
        var seen = Set<Int>()
        return filter { seen.insert($0.rawValue).inserted }
    }
}
