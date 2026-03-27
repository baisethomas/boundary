//
//  CalendarService.swift
//  Boundary
//
//  EventKit-backed, local-first calendar reads (no sync). Fails closed when access is insufficient.
//

import EventKit
import Foundation
import UIKit

@MainActor
final class CalendarService: CalendarServicing {
    private let store: EKEventStore

    init(eventStore: EKEventStore = EKEventStore()) {
        self.store = eventStore
    }

    func authorizationState() async -> CalendarAuthorizationState {
        Self.mapAuthorization(EKEventStore.authorizationStatus(for: .event))
    }

    func requestAccess() async -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    func availableCalendars() async -> [CalendarSource] {
        guard Self.canReadEventsStatus(EKEventStore.authorizationStatus(for: .event)) else {
            return []
        }
        return store.calendars(for: .event).map(Self.makeSource(from:))
    }

    func events(from start: Date, to end: Date) async -> [BoundaryCalendarEvent] {
        guard Self.canReadEventsStatus(EKEventStore.authorizationStatus(for: .event)) else {
            return []
        }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).map { BoundaryCalendarEvent(event: $0) }
    }

    // MARK: - Authorization mapping

    private static func mapAuthorization(_ status: EKAuthorizationStatus) -> CalendarAuthorizationState {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .fullAccess, .authorized:
            return .authorized
        case .writeOnly:
            return .denied
        @unknown default:
            return .denied
        }
    }

    /// Full or legacy “authorized” can read events; write-only cannot.
    private static func canReadEventsStatus(_ status: EKAuthorizationStatus) -> Bool {
        switch status {
        case .fullAccess, .authorized:
            return true
        case .notDetermined, .restricted, .denied, .writeOnly:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Mapping helpers

    private static func makeSource(from calendar: EKCalendar) -> CalendarSource {
        CalendarSource(
            id: calendar.calendarIdentifier,
            title: calendar.title,
            colorHex: calendar.cgColor.flatMap(rgbHex(from:)),
            allowsContentModifications: calendar.allowsContentModifications
        )
    }

    private static func rgbHex(from color: CGColor) -> String? {
        let ui = UIColor(cgColor: color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(
            format: "#%02X%02X%02X",
            Int(round(r * 255)),
            Int(round(g * 255)),
            Int(round(b * 255))
        )
    }
}

// MARK: - EKEvent → domain

private extension BoundaryCalendarEvent {
    init(event: EKEvent) {
        let title = event.title ?? ""
        self.id = event.eventIdentifier ?? UUID().uuidString
        self.calendarID = event.calendar?.calendarIdentifier ?? ""
        self.title = title
        self.start = event.startDate
        self.end = event.endDate
        self.isAllDay = event.isAllDay
        if let loc = event.location, !loc.isEmpty {
            self.location = loc
        } else {
            self.location = nil
        }
        if let notes = event.notes, !notes.isEmpty {
            let maxLen = 500
            self.notesSnippet = notes.count > maxLen ? String(notes.prefix(maxLen)) + "…" : notes
        } else {
            self.notesSnippet = nil
        }
        self.eventType = Self.inferredType(title: title, isAllDay: event.isAllDay)
    }

    private static func inferredType(title: String, isAllDay: Bool) -> CalendarEventType {
        if isAllDay { return .allDay }
        let t = title.lowercased()
        if t.contains("out of office") || t.contains("ooo") {
            return .outOfOffice
        }
        if t.contains("focus") || t.contains("deep work") {
            return .focus
        }
        return .standard
    }
}
