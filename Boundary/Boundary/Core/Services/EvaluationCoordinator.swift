//
//  EvaluationCoordinator.swift
//  Boundary
//
//  PRD Section 14 — foreground / launch refresh (no guaranteed background).
//

import Foundation

@MainActor
final class EvaluationCoordinator {
    private let ruleEngine: any RuleEvaluating
    private let calendarService: any CalendarServicing

    init(ruleEngine: any RuleEvaluating, calendarService: any CalendarServicing) {
        self.ruleEngine = ruleEngine
        self.calendarService = calendarService
    }

    func evaluateForeground(
        rules: [PersistedRule],
        appState: AppState,
        configuration: AppConfiguration?,
        now: Date = .now
    ) async {
        let paused = configuration?.isPaused ?? false
        let events = await calendarService.eventSummaries(around: now)
        let result = ruleEngine.evaluate(
            rules: rules,
            now: now,
            calendarEvents: events,
            isGloballyPaused: paused
        )
        appState.applyEvaluation(result)
    }
}
