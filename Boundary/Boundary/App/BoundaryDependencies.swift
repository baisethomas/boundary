//
//  BoundaryDependencies.swift
//  Boundary
//
//  Single construction site for app-level state + services (shared PermissionsManager identity).
//

import SwiftUI

@MainActor
@Observable
final class BoundaryDependencies {
    let permissionsManager: PermissionsManager
    let appState: AppState
    let rulesStore: RulesStore
    let activityStore: ActivityStore
    let services: ServiceContainer

    init(calendarService: CalendarServicing? = nil) {
        let calendar = calendarService ?? CalendarService()
        let permissions = PermissionsManager(calendarService: calendar)
        permissionsManager = permissions
        appState = AppState()
        rulesStore = RulesStore()
        activityStore = ActivityStore()

        let engine = RuleEngine()
        let automation = AutomationService()
        let activityLogger = ActivityLogger()
        let coordinator = EvaluationCoordinator(
            ruleEngine: engine,
            calendarService: calendar,
            automationService: automation,
            activityLogger: activityLogger
        )
        services = ServiceContainer(
            calendarService: calendar,
            ruleEngine: engine,
            automationService: automation,
            activityLogger: activityLogger,
            permissionsManager: permissions,
            persistence: SwiftDataPersistenceService.shared,
            evaluationCoordinator: coordinator
        )
    }
}
