//
//  CalendarMatchType.swift
//  Boundary
//

import Foundation

/// How calendar event titles are matched against keywords (PRD §9 — partial / case-insensitive baseline).
enum CalendarMatchType: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case keywordPartial
    case keywordExact

    var id: String { rawValue }
}
