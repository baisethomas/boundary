//
//  AppConfiguration.swift
//  Boundary
//
//  PRD AppState persistence slice — onboarding + global pause.
//

import Foundation
import SwiftData

@Model
final class AppConfiguration {
    static let singletonID = "app.configuration.singleton"

    @Attribute(.unique) var id: String
    var hasCompletedOnboarding: Bool
    /// PRD Section 10 — global pause survives relaunch when true.
    var isPaused: Bool = false

    /// Default for new rules in the builder; persisted app preference (PRD §11).
    var defaultRestoreBehaviorRaw: String = RestoreBehavior.revertPrevious.rawValue

    init(
        id: String = AppConfiguration.singletonID,
        hasCompletedOnboarding: Bool = false,
        isPaused: Bool = false,
        defaultRestoreBehaviorRaw: String = RestoreBehavior.revertPrevious.rawValue
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isPaused = isPaused
        self.defaultRestoreBehaviorRaw = defaultRestoreBehaviorRaw
    }
}
