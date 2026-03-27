//
//  AppSettings.swift
//  Boundary
//
//  PRD §7 / §13 — portable settings snapshot (SwiftData singleton remains source of truth in-app).
//

import Foundation

struct AppSettings: Codable, Equatable, Hashable, Sendable {
    var onboardingComplete: Bool
    var isPaused: Bool

    init(onboardingComplete: Bool = false, isPaused: Bool = false) {
        self.onboardingComplete = onboardingComplete
        self.isPaused = isPaused
    }
}
