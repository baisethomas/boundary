//
//  OnboardingWelcomeStepView.swift
//  Boundary
//

import SwiftUI

struct OnboardingWelcomeStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xl) {
            SectionHeader(
                title: "Quiet time, on your terms",
                subtitle: "Boundary ties your calendar and schedule to calm, automatic Focus-style boundaries—so you are not the one toggling switches all day."
            )

            BoundaryCard {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                    bullet("Rules that match how you actually work and rest.")
                    bullet("Clear history when something triggers—or when you override.")
                    bullet("Everything stays on your device in this MVP.")
                }
            }

            PrimaryButton(title: "Continue", systemImage: "arrow.right") {
                viewModel.goForward()
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: BoundaryTheme.Spacing.sm) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(.tertiary)
                .padding(.top, 7)
            Text(text)
                .font(BoundaryTheme.Typography.body)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    let config = AppConfiguration(hasCompletedOnboarding: false)
    return NavigationStack {
        BoundaryScreen {
            OnboardingWelcomeStepView(viewModel: OnboardingViewModel(configuration: config))
        }
    }
}
