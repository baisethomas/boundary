//
//  AppConfiguration+AppSettings.swift
//  Boundary
//

import Foundation

extension AppConfiguration {
    var appSettings: AppSettings {
        get {
            AppSettings(onboardingComplete: hasCompletedOnboarding, isPaused: isPaused)
        }
        set {
            hasCompletedOnboarding = newValue.onboardingComplete
            isPaused = newValue.isPaused
        }
    }

    var defaultRestoreBehavior: RestoreBehavior {
        get { RestoreBehavior(rawValue: defaultRestoreBehaviorRaw) ?? .revertPrevious }
        set { defaultRestoreBehaviorRaw = newValue.rawValue }
    }
}
