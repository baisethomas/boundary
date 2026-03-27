//
//  BoundaryState.swift
//  Boundary
//

import Foundation

/// PRD §10 — runtime boundary state machine (pause is also reflected via evaluation).
enum BoundaryState: Codable, Equatable, Hashable, Sendable {
    case inactive
    case active(ruleId: UUID)
    case paused

    enum CodingKeys: String, CodingKey {
        case kind
        case ruleId
    }

    private enum Kind: String, Codable {
        case inactive
        case active
        case paused
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .inactive:
            self = .inactive
        case .paused:
            self = .paused
        case .active:
            let id = try c.decode(UUID.self, forKey: .ruleId)
            self = .active(ruleId: id)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .inactive:
            try c.encode(Kind.inactive, forKey: .kind)
        case .paused:
            try c.encode(Kind.paused, forKey: .kind)
        case let .active(id):
            try c.encode(Kind.active, forKey: .kind)
            try c.encode(id, forKey: .ruleId)
        }
    }
}
