//
//  HomeViewModel.swift
//  Boundary
//

import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    private let calendarService: any CalendarServicing
    private let evaluationCoordinator: EvaluationCoordinator

    var calendarState: CalendarAuthorizationState = .notDetermined
    var isRefreshing: Bool = false
    var toast: String?

    init(
        calendarService: any CalendarServicing,
        evaluationCoordinator: EvaluationCoordinator
    ) {
        self.calendarService = calendarService
        self.evaluationCoordinator = evaluationCoordinator
    }

    func loadCalendarState() async {
        calendarState = await calendarService.authorizationState()
    }

    func runForegroundEvaluation(
        appState: AppState,
        configuration: AppConfiguration?,
        rules: [PersistedRule],
        activityStore: ActivityStore,
        trigger: EvaluationTrigger = .automatic
    ) async {
        isRefreshing = true
        defer { isRefreshing = false }
        await evaluationCoordinator.evaluateForeground(
            rules: rules,
            appState: appState,
            configuration: configuration,
            activityStore: activityStore,
            trigger: trigger
        )
    }

    func showToast(_ message: String, duration: Duration = .seconds(2)) async {
        toast = message
        try? await Task.sleep(for: duration)
        toast = nil
    }

    // MARK: - Display helpers (keeps views declarative)

    func heroHeadline(appState: AppState) -> String {
        switch appState.currentBoundaryState {
        case .paused:
            return "Paused"
        case .inactive:
            return "No active boundary"
        case .active:
            return appState.lastEvaluation?.activeRuleTitle ?? "Quiet"
        }
    }

    func modeLabel(appState: AppState) -> String {
        switch appState.currentBoundaryState {
        case .paused: "Paused"
        case .inactive: "Off"
        case .active: "Quiet"
        }
    }

    func modeBadgeStyle(appState: AppState) -> StatusBadge.Style {
        switch appState.currentBoundaryState {
        case .active: .active
        case .inactive: .idle
        case .paused: .pending
        }
    }

    func reasonLine(appState: AppState) -> String {
        appState.lastEvaluation?.reason ?? "Run a test or wait for the next evaluation to see why Boundary is on or off."
    }

    func endsSummary(appState: AppState) -> String {
        switch appState.currentBoundaryState {
        case .paused:
            return "Resume when you want rules to apply again — use Quick actions or Settings."
        case .inactive:
            return "Nothing is enforcing quiet time right now."
        case .active:
            if let end = appState.lastEvaluation?.nextTriggerDate {
                return "Around \(end.formatted(date: .abbreviated, time: .shortened))."
            }
            return "When your matching schedule window or calendar event ends. Exact end time will refine as the engine matures."
        }
    }

    func nextBoundarySummary(appState: AppState) -> String {
        appState.lastEvaluation?.nextBoundarySummary ?? "No upcoming boundary scheduled."
    }

    func nextBoundaryDetail(appState: AppState) -> String? {
        if appState.lastEvaluation?.nextBoundarySummary == nil {
            return "Enable a rule or run a test after adding triggers to see what’s next."
        }
        return nil
    }
}
