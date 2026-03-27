//
//  OnboardingViewModel.swift
//  Boundary
//
//  Drives linear onboarding: goal → calendar → preset → starter rule → completion (PRD §3).
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
    private let configuration: AppConfiguration

    private(set) var step: OnboardingStep = .welcome
    var selectedGoal: OnboardingUserGoal?
    var selectedPreset: QuietPreset?
    /// Whether the user tapped “Allow” (actual state still comes from `PermissionsManager`).
    var userRequestedCalendarAccess: Bool = false
    var userSkippedCalendar: Bool = false
    private(set) var starterRuleCreated: Bool = false
    private(set) var lastErrorMessage: String?

    init(configuration: AppConfiguration) {
        self.configuration = configuration
    }

    var canGoForward: Bool {
        switch step {
        case .welcome: true
        case .goal: selectedGoal != nil
        case .calendar: true
        case .preset: selectedPreset != nil
        case .summary: false
        case .success: false
        }
    }

    func goForward() {
        guard canGoForward else { return }
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return }
        if next == .preset {
            applyGoalSuggestionIfNeeded()
        }
        step = next
    }

    /// Summary step: persist starter rule, refresh `RulesStore`, then show success.
    func confirmSummaryAndContinue(using context: ModelContext, rulesStore: RulesStore) {
        createStarterRuleIfNeeded(using: context, rulesStore: rulesStore)
        guard starterRuleCreated else { return }
        step = .success
    }

    func goBack() {
        guard step.allowsBack, step != .welcome else { return }
        guard let previous = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    func applyGoalSuggestionIfNeeded() {
        if selectedPreset == nil, let goal = selectedGoal {
            selectedPreset = goal.suggestedPreset
        }
    }

    func markCalendarGranted() {
        userRequestedCalendarAccess = true
        userSkippedCalendar = false
    }

    func markCalendarSkipped() {
        userSkippedCalendar = true
        userRequestedCalendarAccess = false
    }

    /// EventKit full-access prompt (or mock); refreshes `PermissionsManager`. Only marks “granted” when read access is allowed.
    func requestCalendarAccess(
        calendarService: CalendarServicing,
        permissionsManager: PermissionsManager
    ) async {
        _ = await calendarService.requestAccess()
        await permissionsManager.refreshStatus()
        let state = await calendarService.authorizationState()
        if state == .authorized || state == .mock {
            markCalendarGranted()
        }
    }

    /// Inserts the first `PersistedRule` from the chosen preset. Idempotent if already created.
    func createStarterRuleIfNeeded(using context: ModelContext, rulesStore: RulesStore) {
        guard !starterRuleCreated else { return }
        lastErrorMessage = nil
        let preset = selectedPreset ?? .afterHours
        let title = starterRuleTitle(for: preset)
        context.insert(PersistedRule(title: title, preset: preset))
        do {
            try context.save()
            starterRuleCreated = true
            try? rulesStore.refreshFromPersistence()
        } catch {
            lastErrorMessage = "Couldn’t save your rule. Try again."
        }
    }

    func markOnboardingComplete(using context: ModelContext, rulesStore: RulesStore) {
        configuration.hasCompletedOnboarding = true
        do {
            try context.save()
            try? rulesStore.refreshFromPersistence()
        } catch {
            lastErrorMessage = "Couldn’t finish setup. Try again."
        }
    }

    private func starterRuleTitle(for preset: QuietPreset) -> String {
        preset.displayName
    }
}
