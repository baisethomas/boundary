//
//  QuietModeType.swift
//  Boundary
//

import Foundation

/// High-level Focus / quiet category (maps to system APIs later).
enum QuietModeType: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case doNotDisturb
    case personal
    case work
    case sleep
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .doNotDisturb: "Do Not Disturb"
        case .personal: "Personal"
        case .work: "Work"
        case .sleep: "Sleep"
        case .custom: "Custom"
        }
    }
}
