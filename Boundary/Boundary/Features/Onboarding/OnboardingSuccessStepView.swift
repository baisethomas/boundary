//
//  OnboardingSuccessStepView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct OnboardingSuccessStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(RulesStore.self) private var rulesStore

    var body: some View {
        VStack(spacing: BoundaryTheme.Spacing.xl) {
            Spacer(minLength: BoundaryTheme.Spacing.md)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(BoundaryTheme.Colors.statusEmphasis(colorScheme))
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            VStack(spacing: BoundaryTheme.Spacing.sm) {
                Text("You’re ready")
                    .font(BoundaryTheme.Typography.screenTitle)
                    .multilineTextAlignment(.center)
                Text("Your starter rule is saved. Next time you open Boundary, you’ll see Home, Rules, and Activity.")
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, BoundaryTheme.Spacing.sm)

            if let message = viewModel.lastErrorMessage {
                Text(message)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.red)
            }

            PrimaryButton(title: "Enter Boundary", systemImage: "arrow.right.circle.fill") {
                viewModel.markOnboardingComplete(using: modelContext, rulesStore: rulesStore)
            }

            Spacer(minLength: BoundaryTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    let config = AppConfiguration(hasCompletedOnboarding: false)
    let vm = OnboardingViewModel(configuration: config)
    NavigationStack {
        BoundaryScreen {
            OnboardingSuccessStepView(viewModel: vm)
                .environment(deps.rulesStore)
        }
        .modelContainer(for: [AppConfiguration.self, PersistedRule.self], inMemory: true)
    }
}
