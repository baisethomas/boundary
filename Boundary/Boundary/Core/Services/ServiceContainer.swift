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
}
