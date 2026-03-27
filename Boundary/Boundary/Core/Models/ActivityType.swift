//
//  ActivityType.swift
//  Boundary
//

import Foundation

/// Activity log line items (local-only timeline).
enum ActivityType: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case activated
    case ended
    case skipped
    case override
    case paused
    case resumed

    var id: String { rawValue }
}
