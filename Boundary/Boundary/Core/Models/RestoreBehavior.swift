//
//  RestoreBehavior.swift
//  Boundary
//

import Foundation

/// PRD §11 — when a rule ends.
enum RestoreBehavior: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case revertPrevious
    case `default`
    case maintain

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .revertPrevious: "Revert to previous"
        case .default: "Default state"
        case .maintain: "Maintain current"
        }
    }
}
