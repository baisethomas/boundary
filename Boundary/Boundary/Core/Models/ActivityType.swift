//
//  ActivityType.swift
//  Boundary
//

import Foundation

/// PRD §7 — activity log line items.
enum ActivityType: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case activated
    case ended
    case skipped
    case override

    var id: String { rawValue }
}
