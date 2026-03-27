//
//  OnboardingGoalStepView.swift
//  Boundary
//

import SwiftUI

struct OnboardingGoalStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
            Text("What matters most right now?")
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)

            VStack(spacing: BoundaryTheme.Spacing.sm) {
                ForEach(OnboardingUserGoal.allCases) { goal in
                    OnboardingSelectCard(
                        title: goal.title,
                        subtitle: goal.subtitle,
                        systemImage: goal.symbolName,
                        isSelected: viewModel.selectedGoal == goal
                    ) {
                        viewModel.selectedGoal = goal
                    }
                }
            }

            PrimaryButton(title: "Continue", systemImage: "arrow.right") {
                viewModel.goForward()
            }
            .disabled(viewModel.selectedGoal == nil)
            .opacity(viewModel.selectedGoal == nil ? 0.45 : 1)
        }
    }
}

#Preview {
    let config = AppConfiguration(hasCompletedOnboarding: false)
    return NavigationStack {
        BoundaryScreen {
            OnboardingGoalStepView(viewModel: OnboardingViewModel(configuration: config))
        }
    }
}
