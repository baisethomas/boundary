//
//  ActivityModels.swift
//  Boundary
//

import Foundation

/// Filter chips for the Activity timeline (maps to `ActivityType` where applicable).
enum ActivityFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case activations
    case endings
    case skipped
    case overrides

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .activations: "Activations"
        case .endings: "Endings"
        case .skipped: "Skipped"
        case .overrides: "Overrides"
        }
    }

    func includes(_ type: ActivityType) -> Bool {
        switch self {
        case .all:
            return true
        case .activations:
            return type == .activated
        case .endings:
            return type == .ended
        case .skipped:
            return type == .skipped
        case .overrides:
            return type == .override
        }
    }
}

extension ActivityType {
    /// Short label for badges and filter alignment.
    var displayLabel: String {
        switch self {
        case .activated: "Activation"
        case .ended: "Ended"
        case .skipped: "Skipped"
        case .override: "Override"
        }
    }

    var symbolName: String {
        switch self {
        case .activated: "moon.stars.fill"
        case .ended: "sun.max.fill"
        case .skipped: "arrow.right.circle"
        case .override: "hand.raised.fill"
        }
    }
}
