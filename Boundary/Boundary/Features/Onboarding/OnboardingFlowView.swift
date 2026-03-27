//
//  OnboardingFlowView.swift
//  Boundary
//
//  Linear MVP onboarding container (PRD: < 3 min, first rule created).
//

import SwiftData
import SwiftUI

struct OnboardingFlowView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        NavigationStack {
            BoundaryScreen {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
                    if viewModel.step != .success {
                        OnboardingProgressView(currentStep: viewModel.step)
                    }

                    Group {
                        switch viewModel.step {
                        case .welcome:
                            OnboardingWelcomeStepView(viewModel: viewModel)
                        case .goal:
                            OnboardingGoalStepView(viewModel: viewModel)
                        case .calendar:
                            OnboardingCalendarStepView(viewModel: viewModel)
                        case .preset:
                            OnboardingPresetStepView(viewModel: viewModel)
                        case .summary:
                            OnboardingRuleSummaryStepView(viewModel: viewModel)
                        case .success:
                            OnboardingSuccessStepView(viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.step.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.step.allowsBack {
                        Button {
                            viewModel.goBack()
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                    }
                }
            }
        }
    }
}

#Preview("Full flow") {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    let config = AppConfiguration(hasCompletedOnboarding: false)
    return OnboardingFlowView(viewModel: OnboardingViewModel(configuration: config))
        .environment(deps.permissionsManager)
        .environment(deps.services)
        .environment(deps.rulesStore)
        .modelContainer(for: [AppConfiguration.self, PersistedRule.self, ActivityEvent.self], inMemory: true)
}
