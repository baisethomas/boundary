//
//  PersistedRule.swift
//  Boundary
//
//  SwiftData model — maps to domain `BoundaryRule` for encoding and UI.
//

import Foundation
import SwiftData

@Model
final class PersistedRule {
    var id: UUID
    var title: String
    var isEnabled: Bool
    var presetRaw: String
    var createdAt: Date
    var notes: String

    /// JSON-encoded `RuleTrigger`.
    var triggerData: Data = RuleTrigger.defaultEncoded()
    /// JSON-encoded `QuietModeProfile`.
    var quietProfileData: Data = QuietModeProfile.defaultEncoded
    var restoreBehaviorRaw: String = RestoreBehavior.revertPrevious.rawValue

    init(
        id: UUID = UUID(),
        title: String,
        isEnabled: Bool = true,
        preset: QuietPreset = .afterHours,
        createdAt: Date = .now,
        notes: String = "",
        trigger: RuleTrigger? = nil,
        quietProfile: QuietModeProfile? = nil,
        restoreBehavior: RestoreBehavior? = nil
    ) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.presetRaw = preset.rawValue
        self.createdAt = createdAt
        self.notes = notes
        let resolvedTrigger = trigger ?? QuietPreset.defaultTrigger(for: preset)
        self.triggerData = (try? JSONEncoder().encode(resolvedTrigger)) ?? RuleTrigger.defaultEncoded()
        let profile = quietProfile ?? preset.defaultQuietProfile
        self.quietProfileData = (try? JSONEncoder().encode(profile)) ?? QuietModeProfile.defaultEncoded
        self.restoreBehaviorRaw = (restoreBehavior ?? preset.defaultRestoreBehavior).rawValue
    }

    var preset: QuietPreset {
        get { QuietPreset(rawValue: presetRaw) ?? .afterHours }
        set { presetRaw = newValue.rawValue }
    }

    var trigger: RuleTrigger {
        get {
            guard !triggerData.isEmpty,
                  let decoded = try? JSONDecoder().decode(RuleTrigger.self, from: triggerData)
            else {
                return .schedule(RuleTrigger.defaultAfterHoursSchedule())
            }
            return decoded
        }
        set {
            triggerData = (try? JSONEncoder().encode(newValue)) ?? RuleTrigger.defaultEncoded()
        }
    }

    var quietProfile: QuietModeProfile {
        get {
            guard !quietProfileData.isEmpty,
                  let decoded = try? JSONDecoder().decode(QuietModeProfile.self, from: quietProfileData)
            else {
                return QuietModeProfile.baseline(for: .doNotDisturb)
            }
            return decoded
        }
        set {
            quietProfileData = (try? JSONEncoder().encode(newValue)) ?? QuietModeProfile.defaultEncoded
        }
    }

    var restoreBehavior: RestoreBehavior {
        get { RestoreBehavior(rawValue: restoreBehaviorRaw) ?? .revertPrevious }
        set { restoreBehaviorRaw = newValue.rawValue }
    }

    var boundaryRule: BoundaryRule {
        get {
            BoundaryRule(
                id: id,
                name: title,
                isEnabled: isEnabled,
                trigger: trigger,
                quietMode: quietProfile,
                restoreBehavior: restoreBehavior,
                createdAt: createdAt,
                notes: notes
            )
        }
        set {
            id = newValue.id
            title = newValue.name
            isEnabled = newValue.isEnabled
            trigger = newValue.trigger
            quietProfile = newValue.quietMode
            restoreBehavior = newValue.restoreBehavior
            createdAt = newValue.createdAt
            notes = newValue.notes
        }
    }
}
