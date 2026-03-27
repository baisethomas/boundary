//
//  MockCalendarService.swift
//  Boundary
//
//  Deterministic calendar double for SwiftUI previews and unit tests.
//

import Foundation

@MainActor
final class MockCalendarService: CalendarServicing {
    private var simulatedAuthorization: CalendarAuthorizationState
    private let calendars: [CalendarSource]
    private let storedEvents: [BoundaryCalendarEvent]

    init(
        authorization: CalendarAuthorizationState = .mock,
        calendars: [CalendarSource]? = nil,
        events: [BoundaryCalendarEvent]? = nil
    ) {
        self.simulatedAuthorization = authorization
        self.calendars = calendars ?? Self.defaultCalendars
        self.storedEvents = events ?? Self.defaultEvents
    }

    func authorizationState() async -> CalendarAuthorizationState {
        simulatedAuthorization
    }

    func requestAccess() async -> Bool {
        simulatedAuthorization = .authorized
        return true
    }

    func availableCalendars() async -> [CalendarSource] {
        guard canRead else { return [] }
        return calendars
    }

    func events(from start: Date, to end: Date) async -> [BoundaryCalendarEvent] {
        guard canRead else { return [] }
        return storedEvents.filter { $0.end >= start && $0.start <= end }
    }

    private var canRead: Bool {
        switch simulatedAuthorization {
        case .authorized, .mock:
            return true
        case .notDetermined, .denied, .restricted:
            return false
        }
    }

    private static let defaultCalendars: [CalendarSource] = [
        CalendarSource(
            id: "mock.work",
            title: "Work",
            colorHex: "#5E7CE2",
            allowsContentModifications: false
        ),
        CalendarSource(
            id: "mock.personal",
            title: "Personal",
            colorHex: "#C4C4C4",
            allowsContentModifications: true
        ),
    ]

    private static var defaultEvents: [BoundaryCalendarEvent] {
        let cal = Calendar.current
        let now = Date()
        guard let start = cal.date(byAdding: .hour, value: -1, to: now),
              let end = cal.date(byAdding: .hour, value: 2, to: now),
              let oooStart = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: now)),
              let oooEnd = cal.date(byAdding: .day, value: 2, to: oooStart)
        else {
            return []
        }

        return [
            BoundaryCalendarEvent(
                id: "mock.focus",
                calendarID: "mock.work",
                title: "Deep work — focus block",
                start: start,
                end: end,
                isAllDay: false,
                location: nil,
                notesSnippet: nil,
                eventType: .focus
            ),
            BoundaryCalendarEvent(
                id: "mock.ooo",
                calendarID: "mock.work",
                title: "Out of office",
                start: oooStart,
                end: oooEnd,
                isAllDay: true,
                location: nil,
                notesSnippet: nil,
                eventType: .outOfOffice
            ),
        ]
    }
}
