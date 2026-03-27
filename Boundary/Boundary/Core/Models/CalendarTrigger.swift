//
//  CalendarTrigger.swift
//  Boundary
//
//  PRD §9 — keywords + overlap; extended with match and event-type hints for EventKit.
//

import Foundation

struct CalendarTrigger: Codable, Equatable, Hashable, Sendable {
    var keywords: [String]
    var matchType: CalendarMatchType
    var allowedEventTypes: [CalendarEventType]

    init(
        keywords: [String],
        matchType: CalendarMatchType = .keywordPartial,
        allowedEventTypes: [CalendarEventType] = [.standard]
    ) {
        self.keywords = keywords
        self.matchType = matchType
        self.allowedEventTypes = allowedEventTypes
    }

    func matches(eventTitle: String) -> Bool {
        let trimmed = eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        switch matchType {
        case .keywordPartial:
            return keywords.contains { lower.contains($0.lowercased()) }
        case .keywordExact:
            return keywords.contains { lower == $0.lowercased() }
        }
    }
}
