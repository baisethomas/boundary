//
//  RulesViewModel.swift
//  Boundary
//

import SwiftUI

@MainActor
@Observable
final class RulesViewModel {
    private let ruleEngine: any RuleEvaluating

    init(ruleEngine: any RuleEvaluating) {
        self.ruleEngine = ruleEngine
    }

    func evaluateSummary(for rules: [PersistedRule], isPaused: Bool) -> String {
        let result = ruleEngine.evaluate(
            rules: rules,
            now: .now,
            calendarEvents: [],
            isGloballyPaused: isPaused
        )
        if let title = result.activeRuleTitle {
            return "Active: \(title)"
        }
        return result.reason
    }

    /// Per-card line for whether this rule is firing now or waiting (engine + global pause).
    func runStateLine(for rule: BoundaryRule, appState: AppState) -> String {
        guard rule.isEnabled else { return "Disabled" }
        if appState.isPaused {
            return "Paused — global hold"
        }
        guard let eval = appState.lastEvaluation else {
            return "Waiting for trigger"
        }
        switch eval.boundaryState {
        case .paused:
            return "Paused — global hold"
        case let .active(activeId) where activeId == rule.id:
            return "Active now"
        case .active:
            return "Idle — not matching now"
        case .inactive:
            return "Idle — waiting for next trigger"
        }
    }
}
