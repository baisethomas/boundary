//
//  CalendarService.swift
//  Boundary
//
//  EventKit wiring (EKEventStore, calendars, events) lands here for MVP+.
//

import Foundation

enum CalendarAuthorizationState: String {
    case notDetermined
    case denied
    case authorized
    case restricted
    case mock
}

protocol CalendarServicing: AnyObject {
    func authorizationState() async -> CalendarAuthorizationState
    func requestAccess() async -> Bool
    /// EventKit-backed implementation will return real overlaps; mock returns empty or sample data.
    func eventSummaries(around date: Date) async -> [CalendarEventSummary]
}

/// Placeholder until EventKit is integrated; returns mock-friendly states.
@MainActor
final class CalendarService: CalendarServicing {
    func authorizationState() async -> CalendarAuthorizationState {
        .mock
    }

    func requestAccess() async -> Bool {
        true
    }

    func eventSummaries(around date: Date) async -> [CalendarEventSummary] {
        _ = date
        return []
    }
}
