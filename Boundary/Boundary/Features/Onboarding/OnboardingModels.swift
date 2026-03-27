//
//  OnboardingModels.swift
//  Boundary
//
//  Linear MVP onboarding — steps and user intent (PRD §3, §5).
//

import Foundation

enum OnboardingStep: Int, CaseIterable, Identifiable, Sendable {
    case welcome
    case goal
    case calendar
    case preset
    case summary
    case success

    var id: Int { rawValue }

    var navigationTitle: String {
        switch self {
        case .welcome: "Welcome"
        case .goal: "Your goal"
        case .calendar: "Calendar"
        case .preset: "Choose a preset"
        case .summary: "Your first rule"
        case .success: "You’re set"
        }
    }

    /// Steps shown before the celebration screen (for back navigation).
    var allowsBack: Bool {
        switch self {
        case .welcome, .success: false
        default: true
        }
    }
}

enum OnboardingUserGoal: String, CaseIterable, Identifiable, Sendable {
    case unwindEvenings
    case travelOOO
    case deepFocus
    case familyFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .unwindEvenings: "Unwind after work"
        case .travelOOO: "Travel & out of office"
        case .deepFocus: "Deep focus"
        case .familyFirst: "Family time"
        }
    }

    var subtitle: String {
        switch self {
        case .unwindEvenings: "Quiet evenings and boundaries after the workday."
        case .travelOOO: "Stay undisturbed when you’re away or on vacation."
        case .deepFocus: "Protect heads-down time from pings and noise."
        case .familyFirst: "Be present at home without work bleeding in."
        }
    }

    var symbolName: String {
        switch self {
        case .unwindEvenings: "moon.stars.fill"
        case .travelOOO: "airplane.departure"
        case .deepFocus: "brain.head.profile"
        case .familyFirst: "figure.2.and.child.holdinghands"
        }
    }

    var suggestedPreset: QuietPreset {
        switch self {
        case .unwindEvenings: .afterHours
        case .travelOOO: .outOfOffice
        case .deepFocus: .deepWork
        case .familyFirst: .familyTime
        }
    }
}
