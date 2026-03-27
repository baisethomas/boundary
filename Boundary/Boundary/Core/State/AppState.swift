//
//  AppState.swift
//  Boundary
//
//  Central runtime state: onboarding, pause, boundary evaluation, optional permission mirror.
//

import SwiftUI

@MainActor
@Observable
final class AppState {
    /// Latest engine output; drives Home and automation hooks.
    private(set) var lastEvaluation: RuleEvaluationResult?

    /// Bound from `RootView` when configuration is available.
    var configuration: AppConfiguration?

    /// Refreshed with `PermissionsManager` so shell UIs can read one place (optional mirror).
    private(set) var calendarPermission: CalendarAuthorizationState = .notDetermined

    var currentBoundaryState: BoundaryState {
        lastEvaluation?.boundaryState ?? .inactive
    }

    var onboardingComplete: Bool {
        configuration?.hasCompletedOnboarding ?? false
    }

    var isPaused: Bool {
        configuration?.isPaused ?? false
    }

    func applyEvaluation(_ result: RuleEvaluationResult) {
        lastEvaluation = result
    }

    func syncCalendarPermission(_ status: CalendarAuthorizationState) {
        calendarPermission = status
    }

    func syncConfiguration(_ configuration: AppConfiguration?) {
        self.configuration = configuration
    }
}
