//
//  OnboardingRuleSummaryStepView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct OnboardingRuleSummaryStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(RulesStore.self) private var rulesStore

    private var preset: QuietPreset {
        viewModel.selectedPreset ?? .afterHours
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
            Text("We’ll turn this into your first rule. You can edit or add more anytime.")
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)

            BoundaryCard {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                    summaryRow("Rule name", value: preset.displayName)
                    Divider().opacity(0.35)
                    if let goal = viewModel.selectedGoal {
                        summaryRow("Your goal", value: goal.title)
                        Divider().opacity(0.35)
                    }
                    summaryRow("When it runs", value: preset.onboardingTriggerSummary)
                    Divider().opacity(0.35)
                    summaryRow("Calendar", value: calendarLine)
                }
            }

            if let message = viewModel.lastErrorMessage {
                Text(message)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.red)
            }

            PrimaryButton(title: "Create my rule & continue", systemImage: "plus.circle.fill") {
                viewModel.confirmSummaryAndContinue(using: modelContext, rulesStore: rulesStore)
            }
        }
    }

    private var calendarLine: String {
        if viewModel.userSkippedCalendar {
            return "Skipped — calendar rules will be limited until you allow access in Settings."
        }
        if viewModel.userRequestedCalendarAccess {
            return "Allowed — Boundary can match calendar-backed presets."
        }
        return "Not configured"
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
            Text(label)
                .font(BoundaryTheme.Typography.captionSmall)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(BoundaryTheme.Typography.body)
        }
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    let config = AppConfiguration(hasCompletedOnboarding: false)
    let vm = OnboardingViewModel(configuration: config)
    vm.selectedGoal = .unwindEvenings
    vm.selectedPreset = .afterHours
    return NavigationStack {
        BoundaryScreen {
            OnboardingRuleSummaryStepView(viewModel: vm)
                .environment(deps.rulesStore)
        }
        .modelContainer(PreviewPersistence.inMemoryContainer())
    }
}
