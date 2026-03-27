//
//  AllowedPeopleMode.swift
//  Boundary
//

import Foundation

/// Who can break through during a quiet profile (Focus interstitial parity).
enum AllowedPeopleMode: Codable, Equatable, Hashable, Sendable {
    case none
    case favoritesOnly
    case specific(contactIdentifiers: [String])

    enum CodingKeys: String, CodingKey {
        case kind
        case contactIdentifiers
    }

    private enum Kind: String, Codable {
        case none
        case favoritesOnly
        case specific
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .none:
            self = .none
        case .favoritesOnly:
            self = .favoritesOnly
        case .specific:
            let ids = try c.decodeIfPresent([String].self, forKey: .contactIdentifiers) ?? []
            self = .specific(contactIdentifiers: ids)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try c.encode(Kind.none, forKey: .kind)
        case .favoritesOnly:
            try c.encode(Kind.favoritesOnly, forKey: .kind)
        case let .specific(ids):
            try c.encode(Kind.specific, forKey: .kind)
            try c.encode(ids, forKey: .contactIdentifiers)
        }
    }
}
