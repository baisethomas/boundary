//
//  AllowedAppsMode.swift
//  Boundary
//

import Foundation

/// Which apps may notify during a quiet profile.
enum AllowedAppsMode: Codable, Equatable, Hashable, Sendable {
    case none
    case specific(bundleIdentifiers: [String])

    enum CodingKeys: String, CodingKey {
        case kind
        case bundleIdentifiers
    }

    private enum Kind: String, Codable {
        case none
        case specific
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .none:
            self = .none
        case .specific:
            let ids = try c.decodeIfPresent([String].self, forKey: .bundleIdentifiers) ?? []
            self = .specific(bundleIdentifiers: ids)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try c.encode(Kind.none, forKey: .kind)
        case let .specific(ids):
            try c.encode(Kind.specific, forKey: .kind)
            try c.encode(ids, forKey: .bundleIdentifiers)
        }
    }
}
