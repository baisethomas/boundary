//
//  CalendarServicing.swift
//  Boundary
//
//  Calendar authorization + read API. Production: `CalendarService` (EventKit).
//  Previews/tests: `MockCalendarService`.
//

import Foundation

enum CalendarAuthorizationState: String, Sendable {
    case notDetermined
    case denied
    case authorized
    case restricted
    /// Test double / canvas previews — not reported by EventKit.
    case mock
}

/// Local-first calendar reads; no sync engine.
protocol CalendarServicing: AnyObject {
    func authorizationState() async -> CalendarAuthorizationState
    /// Requests **full** read access (required for event matching). Returns whether full read is granted.
    func requestAccess() async -> Bool
    /// Writable when authorized; empty when denied / restricted / not determined.
    func availableCalendars() async -> [CalendarSource]
    /// Events overlapping `[start, end]` (inclusive overlap). Empty when not authorized to read.
    func events(from start: Date, to end: Date) async -> [BoundaryCalendarEvent]
    /// Convenience window for evaluation (~previous day through day after `date`).
    func eventSummaries(around date: Date) async -> [CalendarEventSummary]
}

extension CalendarServicing {
    func eventSummaries(around date: Date) async -> [CalendarEventSummary] {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        guard let rangeStart = cal.date(byAdding: .day, value: -1, to: dayStart),
              let rangeEnd = cal.date(byAdding: .day, value: 2, to: dayStart)
        else {
            return []
        }
        let events = await events(from: rangeStart, to: rangeEnd)
        return events.map(\.eventSummary)
    }
}
