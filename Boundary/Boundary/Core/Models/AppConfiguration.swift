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

    init(
        id: String = AppConfiguration.singletonID,
        hasCompletedOnboarding: Bool = false,
        isPaused: Bool = false
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.isPaused = isPaused
    }
}
