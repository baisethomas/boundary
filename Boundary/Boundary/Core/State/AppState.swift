//
//  AppState.swift
//  Boundary
//
//  PRD Section 6 — runtime boundary + last evaluation (onboarding/pause stay in SwiftData).
//

import SwiftUI

@MainActor
@Observable
final class AppState {
    /// Latest engine output; drives Home and automation hooks.
    private(set) var lastEvaluation: RuleEvaluationResult?

    /// Bound from `RootView` when configuration is available.
    var configuration: AppConfiguration?

    var currentBoundaryState: BoundaryState {
        lastEvaluation?.boundaryState ?? .inactive
    }

    var onboardingComplete: Bool {
        configuration?.hasCompletedOnboarding ?? false
    }

    func applyEvaluation(_ result: RuleEvaluationResult) {
        lastEvaluation = result
    }
}
