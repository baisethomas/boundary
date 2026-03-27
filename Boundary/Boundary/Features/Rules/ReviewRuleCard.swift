//
//  ReviewRuleCard.swift
//  Boundary
//

import SwiftUI

/// Read-only summary before save (driven by `RuleBuilderViewModel` draft).
struct ReviewRuleCard: View {
    @Bindable var viewModel: RuleBuilderViewModel

    var body: some View {
        BoundaryCard(elevated: true) {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                Text("Summary")
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text(viewModel.ruleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled rule" : viewModel.ruleName)
                    .font(.title3.weight(.semibold))

                reviewRow("Trigger type", value: viewModel.triggerKind.displayName)
                Divider().opacity(0.35)
                reviewRow("Trigger detail", value: viewModel.reviewTriggerDetail, multiline: true)
                Divider().opacity(0.35)
                reviewRow("Quiet mode", value: viewModel.reviewQuietLine)
                Divider().opacity(0.35)
                reviewRow("When it ends", value: viewModel.restoreBehavior.displayName)
            }
        }
    }

    private func reviewRow(_ title: String, value: String, multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
            Text(title)
                .font(BoundaryTheme.Typography.captionSmall)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(BoundaryTheme.Typography.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: multiline)
        }
    }
}

#Preview {
    ReviewRuleCard(viewModel: RuleBuilderViewModel())
        .padding()
}
