//
//  ActivityLogger.swift
//  Boundary
//

import Foundation

protocol ActivityLogging: AnyObject {
    func record(
        title: String,
        detail: String,
        activityType: ActivityType,
        ruleID: UUID?,
        at date: Date,
        in store: ActivityStore
    )
}

extension ActivityLogging {
    func logRuleActivated(rule: PersistedRule, store: ActivityStore, at date: Date = .now) {
        record(
            title: "Rule activated",
            detail: "«\(rule.title)» is now the active boundary.",
            activityType: .activated,
            ruleID: rule.id,
            at: date,
            in: store
        )
    }

    func logRuleEnded(rule: PersistedRule, restoreSummary: String, store: ActivityStore, at date: Date = .now) {
        record(
            title: "Rule ended",
            detail: "«\(rule.title)» no longer matches. \(restoreSummary)",
            activityType: .ended,
            ruleID: rule.id,
            at: date,
            in: store
        )
    }

    func logRulesSkipped(summary: String, store: ActivityStore, at date: Date = .now) {
        record(
            title: "Rules skipped",
            detail: summary,
            activityType: .skipped,
            ruleID: nil,
            at: date,
            in: store
        )
    }

    func logManualEvaluation(store: ActivityStore, at date: Date = .now) {
        record(
            title: "Manual refresh",
            detail: "Evaluation was run from the Home screen.",
            activityType: .override,
            ruleID: nil,
            at: date,
            in: store
        )
    }

    func logRuleToggled(name: String, ruleId: UUID, enabled: Bool, store: ActivityStore, at date: Date = .now) {
        record(
            title: enabled ? "Rule enabled" : "Rule disabled",
            detail: "«\(name)» was turned \(enabled ? "on" : "off") manually.",
            activityType: .override,
            ruleID: ruleId,
            at: date,
            in: store
        )
    }

    func logBoundaryPaused(store: ActivityStore, at date: Date = .now) {
        record(
            title: "Boundary paused",
            detail: "Automation is on hold until you resume — rules are not applied while paused.",
            activityType: .paused,
            ruleID: nil,
            at: date,
            in: store
        )
    }

    func logRuleSavedFromBuilder(title: String, isEditing: Bool, ruleId: UUID?, store: ActivityStore, at date: Date = .now) {
        record(
            title: isEditing ? "Rule updated" : "Rule created",
            detail: "«\(title)» was saved from the rule builder.",
            activityType: .override,
            ruleID: ruleId,
            at: date,
            in: store
        )
    }

    func logBoundaryResumed(store: ActivityStore, activeRuleTitle: String?, at date: Date = .now) {
        let detail: String
        if let title = activeRuleTitle {
            detail = "Boundary is active again. Current match: «\(title)»."
        } else {
            detail = "Boundary is active again — no rule is matching yet."
        }
        record(
            title: "Boundary resumed",
            detail: detail,
            activityType: .resumed,
            ruleID: nil,
            at: date,
            in: store
        )
    }
}

@MainActor
final class ActivityLogger: ActivityLogging {
    func record(
        title: String,
        detail: String,
        activityType: ActivityType,
        ruleID: UUID? = nil,
        at date: Date = .now,
        in store: ActivityStore
    ) {
        try? store.append(title: title, detail: detail, activityType: activityType, ruleID: ruleID, at: date)
    }
}
