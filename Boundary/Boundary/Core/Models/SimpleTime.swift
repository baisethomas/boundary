//
//  SimpleTime.swift
//  Boundary
//

import Foundation

/// Wall-clock time for schedule windows (not tied to a calendar day).
struct SimpleTime: Codable, Equatable, Hashable, Sendable, Comparable {
    var hour: Int
    var minute: Int

    init(hour: Int, minute: Int = 0) {
        self.hour = min(23, max(0, hour))
        self.minute = min(59, max(0, minute))
    }

    /// Minutes from midnight in [0, 24*60).
    var minutesFromMidnight: Int {
        min(24 * 60 - 1, hour * 60 + minute)
    }

    static func < (lhs: SimpleTime, rhs: SimpleTime) -> Bool {
        lhs.minutesFromMidnight < rhs.minutesFromMidnight
    }

    static let midnight = SimpleTime(hour: 0, minute: 0)
    static let endOfDay = SimpleTime(hour: 23, minute: 59)
}
