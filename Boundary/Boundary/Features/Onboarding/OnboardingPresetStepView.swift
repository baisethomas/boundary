//
//  OnboardingPresetStepView.swift
//  Boundary
//

import SwiftUI

struct OnboardingPresetStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
            if let goal = viewModel.selectedGoal {
                Group {
                    Text("Based on ") + Text(goal.title).fontWeight(.semibold) + Text(" we suggested ") + Text(goal.suggestedPreset.displayName).fontWeight(.semibold) + Text(". Change it below if you like.")
                }
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)
            } else {
                Text("Pick a starter preset. You can fine-tune triggers later.")
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: BoundaryTheme.Spacing.sm) {
                ForEach(QuietPreset.allCases) { preset in
                    OnboardingSelectCard(
                        title: preset.displayName,
                        subtitle: preset.subtitle,
                        systemImage: symbol(for: preset),
                        isSelected: viewModel.selectedPreset == preset
                    ) {
                        viewModel.selectedPreset = preset
                    }
                }
            }

            PrimaryButton(title: "Continue", systemImage: "arrow.right") {
                viewModel.goForward()
            }
            .disabled(viewModel.selectedPreset == nil)
            .opacity(viewModel.selectedPreset == nil ? 0.45 : 1)
        }
    }

    private func symbol(for preset: QuietPreset) -> String {
        switch preset {
        case .afterHours: "moon.stars.fill"
        case .outOfOffice: "airplane.departure"
        case .deepWork: "brain.head.profile"
        case .familyTime: "house.fill"
        }
    }
}

#Preview {
    let config = AppConfiguration(hasCompletedOnboarding: false)
    let vm = OnboardingViewModel(configuration: config)
    vm.selectedGoal = .deepFocus
    vm.applyGoalSuggestionIfNeeded()
    return NavigationStack {
        BoundaryScreen {
            OnboardingPresetStepView(viewModel: vm)
        }
    }
}
