//
//  QuietModeProfile.swift
//  Boundary
//

import Foundation

/// Describes how aggressively we quiet notifications / who & what may break through (Focus orchestration later).
struct QuietModeProfile: Codable, Equatable, Hashable, Identifiable, Sendable {
    var id: UUID
    var displayName: String
    var modeType: QuietModeType
    var people: AllowedPeopleMode
    var apps: AllowedAppsMode

    init(
        id: UUID = UUID(),
        displayName: String,
        modeType: QuietModeType,
        people: AllowedPeopleMode = .none,
        apps: AllowedAppsMode = .none
    ) {
        self.id = id
        self.displayName = displayName
        self.modeType = modeType
        self.people = people
        self.apps = apps
    }

    static func baseline(for modeType: QuietModeType, name: String? = nil) -> QuietModeProfile {
        QuietModeProfile(
            displayName: name ?? modeType.displayName,
            modeType: modeType,
            people: .none,
            apps: .none
        )
    }

    static var defaultEncoded: Data {
        (try? JSONEncoder().encode(QuietModeProfile.baseline(for: .doNotDisturb))) ?? Data()
    }
}
