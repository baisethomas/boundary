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
}
