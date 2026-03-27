//
//  AutomationService.swift
//  Boundary
//
//  Bridges rule outcomes to Focus / system behavior (MVP: local state + restore hooks).
//

import Foundation

protocol AutomationServicing: AnyObject {
    /// Apply automation for the winning rule, or clear to a neutral boundary when `nil`.
    func applyBoundary(for rule: PersistedRule?) async
    /// When a rule ends, apply its restore preference (local-only MVP).
    func applyRestore(
        behavior: RestoreBehavior,
        priorActiveRuleId: UUID?,
        allRules: [PersistedRule]
    ) async
}

@MainActor
final class AutomationService: AutomationServicing {
    /// Last rule handed to automation (nil = default / cleared). For debugging and future Focus APIs.
    private(set) var lastAppliedRuleId: UUID?

    func applyBoundary(for rule: PersistedRule?) async {
        lastAppliedRuleId = rule?.id
        // Future: configure Focus filters / DND from `rule?.quietProfile`
    }

    func applyRestore(
        behavior: RestoreBehavior,
        priorActiveRuleId: UUID?,
        allRules: [PersistedRule]
    ) async {
        switch behavior {
        case .revertPrevious:
            if let pid = priorActiveRuleId,
               let previous = allRules.first(where: { $0.id == pid && $0.isEnabled }) {
                await applyBoundary(for: previous)
            } else {
                await applyBoundary(for: nil)
            }
        case .default:
            await applyBoundary(for: nil)
        case .maintain:
            break
        }
    }
}
