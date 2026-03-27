//
//  QuietMode.swift
//  Boundary
//

import Foundation

/// Maps to Focus / quiet behavior once AutomationService is wired (PRD Section 11).
enum QuietMode: String, Codable, CaseIterable, Identifiable {
    case doNotDisturb
    case work
    case personal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .doNotDisturb: "Do Not Disturb"
        case .work: "Work"
        case .personal: "Personal"
        }
    }
}
