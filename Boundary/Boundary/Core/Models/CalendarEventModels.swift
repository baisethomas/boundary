//
//  CalendarEventModels.swift
//  Boundary
//
//  App-local calendar types (EventKit-free) for evaluation, UI, and tests.
//

import Foundation

/// Minimal overlap payload for rule evaluation (keyword / time window checks).
struct CalendarEventSummary: Equatable, Sendable {
    var title: String
    var start: Date
    var end: Date
    /// Used with `CalendarTrigger.allowedEventTypes`; defaults to `.standard` when unknown.
    var eventType: CalendarEventType

    init(title: String, start: Date, end: Date, eventType: CalendarEventType = .standard) {
        self.title = title
        self.start = start
        self.end = end
        self.eventType = eventType
    }
}

/// A user-visible calendar source (maps from `EKCalendar`).
struct CalendarSource: Equatable, Sendable, Identifiable {
    var id: String
    var title: String
    /// RGB hex like `#RRGGBB` for swatches; nil when no color is available.
    var colorHex: String?
    var allowsContentModifications: Bool
}

/// Full-fidelity-ish event snapshot for UI and future filtering; maps from `EKEvent`.
struct BoundaryCalendarEvent: Equatable, Sendable, Identifiable {
    var id: String
    var calendarID: String
    var title: String
    var start: Date
    var end: Date
    var isAllDay: Bool
    var location: String?
    /// Truncated notes for on-device display only.
    var notesSnippet: String?
    var eventType: CalendarEventType

    var eventSummary: CalendarEventSummary {
        CalendarEventSummary(title: title, start: start, end: end, eventType: eventType)
    }
}
