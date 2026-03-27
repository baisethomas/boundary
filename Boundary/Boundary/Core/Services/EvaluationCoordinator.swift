//
//  EvaluationCoordinator.swift
//  Boundary
//
//  Foreground evaluation, activity logging, automation + restore on rule lifecycle.
//

import Foundation

enum EvaluationTrigger: Sendable {
    case automatic
    case manual
}

@MainActor
final class EvaluationCoordinator {
    private let ruleEngine: any RuleEvaluating
    private let calendarService: any CalendarServicing
    private let automationService: any AutomationServicing
    private let activityLogger: any ActivityLogging

    /// For `revertPrevious`: which rule was active immediately before `key` became active (`nil` = none).
    private var priorRuleWhenActivated: [UUID: UUID?] = [:]

    init(
        ruleEngine: any RuleEvaluating,
        calendarService: any CalendarServicing,
        automationService: any AutomationServicing,
        activityLogger: any ActivityLogging
    ) {
        self.ruleEngine = ruleEngine
        self.calendarService = calendarService
        self.automationService = automationService
        self.activityLogger = activityLogger
    }

    func evaluateForeground(
        rules: [PersistedRule],
        appState: AppState,
        configuration: AppConfiguration?,
        activityStore: ActivityStore,
        trigger: EvaluationTrigger = .automatic,
        now: Date = .now
    ) async {
        let previous = appState.lastEvaluation
        let wasPaused = previous?.boundaryState == .paused

        let globallyPaused = configuration?.isPaused ?? false
        let events = await calendarService.eventSummaries(around: now)
        let result = ruleEngine.evaluate(
            rules: rules,
            now: now,
            calendarEvents: events,
            isGloballyPaused: globallyPaused,
            calendar: Calendar.current
        )

        let ruleById = Dictionary(uniqueKeysWithValues: rules.map { ($0.id, $0) })
        let oldActive = activeRuleId(from: previous)
        let newActive = result.activeRuleId
        let nowPaused = result.boundaryState == .paused

        if nowPaused {
            if !wasPaused {
                activityLogger.logBoundaryPaused(store: activityStore, at: now)
            }
            appState.applyEvaluation(result)
            if trigger == .manual {
                activityLogger.logManualEvaluation(store: activityStore, at: now)
                logSkippedIfNeeded(result: result, store: activityStore, now: now, trigger: trigger)
            }
            return
        }

        if wasPaused {
            let title = newActive.flatMap { ruleById[$0]?.title }
            activityLogger.logBoundaryResumed(store: activityStore, activeRuleTitle: title, at: now)
            if let n = newActive {
                await automationService.applyBoundary(for: ruleById[n])
            } else {
                await automationService.applyBoundary(for: nil)
            }
            appState.applyEvaluation(result)
            if trigger == .manual {
                activityLogger.logManualEvaluation(store: activityStore, at: now)
                logSkippedIfNeeded(result: result, store: activityStore, now: now, trigger: trigger)
            }
            return
        }

        if oldActive != newActive {
            if let ended = oldActive {
                await endActivatedRule(
                    id: ended,
                    rules: rules,
                    ruleById: ruleById,
                    store: activityStore,
                    at: now
                )
            }
            if let started = newActive {
                await beginActivatedRule(
                    id: started,
                    previousAutomationTargetId: oldActive,
                    ruleById: ruleById,
                    store: activityStore,
                    at: now
                )
            }
        } else if let n = newActive {
            await automationService.applyBoundary(for: ruleById[n])
        }

        appState.applyEvaluation(result)

        if trigger == .manual {
            activityLogger.logManualEvaluation(store: activityStore, at: now)
        }
        logSkippedIfNeeded(result: result, store: activityStore, now: now, trigger: trigger)
    }

    private func activeRuleId(from evaluation: RuleEvaluationResult?) -> UUID? {
        guard let evaluation else { return nil }
        switch evaluation.boundaryState {
        case .active:
            return evaluation.activeRuleId
        case .inactive, .paused:
            return nil
        }
    }

    private func beginActivatedRule(
        id: UUID,
        previousAutomationTargetId: UUID?,
        ruleById: [UUID: PersistedRule],
        store: ActivityStore,
        at date: Date
    ) async {
        guard let rule = ruleById[id] else { return }
        priorRuleWhenActivated[id] = previousAutomationTargetId
        activityLogger.logRuleActivated(rule: rule, store: store, at: date)
        await automationService.applyBoundary(for: rule)
    }

    private func endActivatedRule(
        id: UUID,
        rules: [PersistedRule],
        ruleById: [UUID: PersistedRule],
        store: ActivityStore,
        at date: Date
    ) async {
        guard let rule = ruleById[id] else { return }
        let prior = priorRuleWhenActivated.removeValue(forKey: id).flatMap { $0 }
        let restoreSummary = restoreSummary(for: rule.restoreBehavior)
        activityLogger.logRuleEnded(rule: rule, restoreSummary: restoreSummary, store: store, at: date)
        await automationService.applyRestore(
            behavior: rule.restoreBehavior,
            priorActiveRuleId: prior,
            allRules: rules
        )
    }

    private func restoreSummary(for behavior: RestoreBehavior) -> String {
        switch behavior {
        case .revertPrevious:
            return "Restore: revert to the previous active rule, or default if none."
        case .default:
            return "Restore: default boundary state."
        case .maintain:
            return "Restore: keep current quiet settings until you change them."
        }
    }

    private func logSkippedIfNeeded(
        result: RuleEvaluationResult,
        store: ActivityStore,
        now: Date,
        trigger: EvaluationTrigger
    ) {
        guard trigger == .manual else { return }
        guard !result.skippedRules.isEmpty else { return }
        let lines = result.skippedRules.prefix(8).map { "• «\($0.ruleTitle)»: \($0.reason)" }.joined(separator: "\n")
        let extra = result.skippedRules.count > 8 ? "\n… and \(result.skippedRules.count - 8) more" : ""
        activityLogger.logRulesSkipped(summary: lines + extra, store: store, at: now)
    }
}
