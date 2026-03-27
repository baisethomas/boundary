//
//  RuleEvaluationTypes.swift
//  Boundary
//
//  Outputs from `RuleEngine` — boundary state, explainability, and scheduling hints.
//

import Foundation

/// Why an enabled rule did not become the active boundary (or was not satisfied).
struct SkippedRuleEvaluation: Equatable, Sendable {
    var ruleId: UUID
    var ruleTitle: String
    var reason: String
}

/// Deterministic evaluation snapshot at `evaluatedAt`.
struct RuleEvaluationResult: Sendable {
    var boundaryState: BoundaryState
    var activeRuleId: UUID?
    var activeRuleTitle: String?
    /// Human-readable explanation of the winning outcome.
    var reason: String
    /// When inactive: next time a rule may activate. When active: when the current boundary is expected to end (best effort).
    var nextTriggerDate: Date?
    var evaluatedAt: Date
    var nextBoundarySummary: String?
    /// Non-winning enabled rules and why they did not apply (or were lower priority).
    var skippedRules: [SkippedRuleEvaluation]
}
