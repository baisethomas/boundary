//
//  PersistedRule.swift
//  Boundary
//
//  PRD BoundaryRule — persisted shape; `title` is the user-facing name.
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

    /// JSON-encoded `RuleTrigger` (schedule / calendar / hybrid).
    var triggerData: Data = RuleTrigger.defaultEncoded()
    var quietModeRaw: String = QuietMode.doNotDisturb.rawValue
    var restoreBehaviorRaw: String = RestoreBehavior.revertPrevious.rawValue

    init(
        id: UUID = UUID(),
        title: String,
        isEnabled: Bool = true,
        preset: QuietPreset = .afterHours,
        createdAt: Date = .now,
        notes: String = "",
        trigger: RuleTrigger? = nil,
        quietMode: QuietMode? = nil,
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
        self.quietModeRaw = (quietMode ?? preset.defaultQuietMode).rawValue
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

    var quietMode: QuietMode {
        get { QuietMode(rawValue: quietModeRaw) ?? .doNotDisturb }
        set { quietModeRaw = newValue.rawValue }
    }

    var restoreBehavior: RestoreBehavior {
        get { RestoreBehavior(rawValue: restoreBehaviorRaw) ?? .revertPrevious }
        set { restoreBehaviorRaw = newValue.rawValue }
    }
}
