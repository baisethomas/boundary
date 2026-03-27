//
//  RuleTrigger.swift
//  Boundary
//
//  PRD §7 — schedule, calendar, hybrid.
//

import Foundation

enum RuleTrigger: Equatable, Hashable, Sendable {
    case schedule(ScheduleTrigger)
    case calendar(CalendarTrigger)
    case hybrid(schedule: ScheduleTrigger, calendar: CalendarTrigger)

    static func defaultAfterHoursSchedule() -> ScheduleTrigger {
        ScheduleTrigger(
            weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            start: SimpleTime(hour: 18),
            end: SimpleTime(hour: 8)
        )
    }

    static func defaultCalendarTrigger() -> CalendarTrigger {
        CalendarTrigger(keywords: ["OOO", "Vacation", "Focus"])
    }

    static func defaultEncoded() -> Data {
        let trigger = RuleTrigger.schedule(defaultAfterHoursSchedule())
        return (try? JSONEncoder().encode(TriggerCodable(from: trigger))) ?? Data()
    }
}

// MARK: - Codable (stable JSON for SwiftData)

private struct TriggerCodable: Codable {
    var kind: Kind
    var schedule: ScheduleTrigger?
    var calendar: CalendarTrigger?

    enum Kind: String, Codable {
        case schedule
        case calendar
        case hybrid
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case schedule
        case calendar
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = try c.decode(Kind.self, forKey: .kind)
        schedule = try c.decodeIfPresent(ScheduleTrigger.self, forKey: .schedule)
        calendar = try c.decodeIfPresent(CalendarTrigger.self, forKey: .calendar)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind, forKey: .kind)
        try c.encodeIfPresent(schedule, forKey: .schedule)
        try c.encodeIfPresent(calendar, forKey: .calendar)
    }

    init(from trigger: RuleTrigger) {
        switch trigger {
        case let .schedule(s):
            kind = .schedule
            schedule = s
            calendar = nil
        case let .calendar(cal):
            kind = .calendar
            schedule = nil
            calendar = cal
        case let .hybrid(s, cal):
            kind = .hybrid
            schedule = s
            calendar = cal
        }
    }

    func asRuleTrigger() -> RuleTrigger? {
        switch kind {
        case .schedule:
            guard let schedule else { return nil }
            return .schedule(schedule)
        case .calendar:
            guard let calendar else { return nil }
            return .calendar(calendar)
        case .hybrid:
            guard let schedule, let calendar else { return nil }
            return .hybrid(schedule: schedule, calendar: calendar)
        }
    }
}

extension RuleTrigger: Codable {
    init(from decoder: Decoder) throws {
        let wrapper = try TriggerCodable(from: decoder)
        guard let trigger = wrapper.asRuleTrigger() else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid trigger payload"))
        }
        self = trigger
    }

    func encode(to encoder: Encoder) throws {
        try TriggerCodable(from: self).encode(to: encoder)
    }
}
