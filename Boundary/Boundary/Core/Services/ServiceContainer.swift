//
//  ServiceContainer.swift
//  Boundary
//

import SwiftUI

@MainActor
@Observable
final class ServiceContainer {
    let calendarService: CalendarServicing
    let ruleEngine: RuleEvaluating
    let automationService: AutomationServicing
    let activityLogger: ActivityLogging
    let permissionsManager: PermissionsManaging
    let persistence: PersistenceServicing
    let evaluationCoordinator: EvaluationCoordinator

    init(
        calendarService: CalendarServicing,
        ruleEngine: RuleEvaluating,
        automationService: AutomationServicing,
        activityLogger: ActivityLogging,
        permissionsManager: PermissionsManaging,
        persistence: PersistenceServicing,
        evaluationCoordinator: EvaluationCoordinator
    ) {
        self.calendarService = calendarService
        self.ruleEngine = ruleEngine
        self.automationService = automationService
        self.activityLogger = activityLogger
        self.permissionsManager = permissionsManager
        self.persistence = persistence
        self.evaluationCoordinator = evaluationCoordinator
    }

    static let live: ServiceContainer = {
        let calendar = CalendarService()
        let engine = RuleEngine()
        let coordinator = EvaluationCoordinator(ruleEngine: engine, calendarService: calendar)
        return ServiceContainer(
            calendarService: calendar,
            ruleEngine: engine,
            automationService: AutomationService(),
            activityLogger: ActivityLogger(),
            permissionsManager: PermissionsManager(),
            persistence: SwiftDataPersistenceService.shared,
            evaluationCoordinator: coordinator
        )
    }()

    static let preview: ServiceContainer = {
        let calendar = CalendarService()
        let engine = RuleEngine()
        let coordinator = EvaluationCoordinator(ruleEngine: engine, calendarService: calendar)
        return ServiceContainer(
            calendarService: calendar,
            ruleEngine: engine,
            automationService: AutomationService(),
            activityLogger: ActivityLogger(),
            permissionsManager: PermissionsManager(),
            persistence: SwiftDataPersistenceService.shared,
            evaluationCoordinator: coordinator
        )
    }()
}
