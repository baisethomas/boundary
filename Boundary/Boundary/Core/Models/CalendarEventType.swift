//
//  CalendarEventType.swift
//  Boundary
//

import Foundation

/// EventKit-oriented categories for future filtering (MVP: stored + displayed; engine may ignore).
enum CalendarEventType: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case standard
    case allDay
    case outOfOffice
    case focus

    var id: String { rawValue }
}
