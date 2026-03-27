//
//  OnboardingComponents.swift
//  Boundary
//
//  Shared calm UI for the onboarding flow (previews supported on each step).
//

import SwiftUI

struct OnboardingProgressView: View {
    let currentStep: OnboardingStep

    private var progress: Double {
        Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
            HStack {
                Text("Setup")
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.tertiary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Onboarding step \(currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")

            ProgressView(value: progress)
                .tint(.primary.opacity(0.55))
        }
    }
}

struct OnboardingSelectCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let subtitle: String
    var systemImage: String?
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: BoundaryTheme.Spacing.md) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                        .frame(width: 36, alignment: .center)
                }
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                    Text(title)
                        .font(BoundaryTheme.Typography.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(BoundaryTheme.Typography.bodySecondary)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(BoundaryTheme.Spacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous)
                    .fill(BoundaryTheme.Colors.cardBackground(colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? Color.accentColor.opacity(0.45)
                            : BoundaryTheme.Colors.separator(colorScheme),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Progress") {
    OnboardingProgressView(currentStep: .preset)
        .padding()
}

#Preview("Card") {
    OnboardingSelectCard(
        title: "After Hours",
        subtitle: "Wind down outside work hours.",
        systemImage: "moon.fill",
        isSelected: true,
        action: {}
    )
    .padding()
}
