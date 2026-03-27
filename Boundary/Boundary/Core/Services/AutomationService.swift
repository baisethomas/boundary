//
//  AutomationService.swift
//  Boundary
//
//  Bridges rule outcomes to Focus / notifications behavior (MVP: stub).
//

import Foundation

protocol AutomationServicing: AnyObject {
    func applyBoundary(for rule: PersistedRule?) async
}

@MainActor
final class AutomationService: AutomationServicing {
    func applyBoundary(for rule: PersistedRule?) async {
        _ = rule
    }
}
