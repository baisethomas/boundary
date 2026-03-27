//
//  Weekday.swift
//  Boundary
//

import Foundation

/// Gregorian weekday, aligned with `Calendar.Component.weekday` (1 = Sunday … 7 = Saturday).
enum Weekday: Int, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    /// Index used with `Calendar.current.component(.weekday, from:)`.
    var gregorianIndex: Int { rawValue }

    var shortSymbol: String {
        Calendar.current.shortWeekdaySymbols[safe: rawValue - 1] ?? ""
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
