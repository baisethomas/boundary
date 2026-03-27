//
//  CurrentStateHeroCard.swift
//  Boundary
//
//  Primary dashboard hero — current boundary state, mode, reason, and end guidance.
//

import SwiftUI

struct CurrentStateHeroCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let headline: String
    let modeLabel: String
    var badgeStyle: StatusBadge.Style
    let reason: String
    let endsSummary: String
    var quietModeName: String?

    var body: some View {
        BoundaryCard(elevated: true) {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
                        Text("Now")
                            .font(BoundaryTheme.Typography.captionSmall)
                            .foregroundStyle(.tertiary)
                            .textCase(.uppercase)
                            .tracking(0.6)

                        Text(headline)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: BoundaryTheme.Spacing.sm)
                    StatusBadge(text: modeLabel, style: badgeStyle)
                }

                if let quietModeName, !quietModeName.isEmpty {
                    HStack(spacing: BoundaryTheme.Spacing.xs) {
                        Image(systemName: "moon.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BoundaryTheme.Colors.statusEmphasis(colorScheme))
                        Text(quietModeName)
                            .font(BoundaryTheme.Typography.bodySecondary.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
                    Label {
                        Text(reason)
                            .font(BoundaryTheme.Typography.bodySecondary)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .labelStyle(.titleAndIcon)

                    Divider()
                        .opacity(0.35)
                        .padding(.vertical, BoundaryTheme.Spacing.xxs)

                    HStack(alignment: .top, spacing: BoundaryTheme.Spacing.sm) {
                        Image(systemName: "clock")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.tertiary)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                            Text("When it ends")
                                .font(BoundaryTheme.Typography.captionSmall)
                                .foregroundStyle(.tertiary)
                            Text(endsSummary)
                                .font(BoundaryTheme.Typography.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

#Preview("Active") {
    CurrentStateHeroCard(
        headline: "After Hours",
        modeLabel: "Quiet",
        badgeStyle: .active,
        reason: "Schedule window matched — weeknights outside work hours.",
        endsSummary: "Ends when the schedule window closes (exact end time coming soon).",
        quietModeName: "Do Not Disturb"
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Paused") {
    CurrentStateHeroCard(
        headline: "Paused",
        modeLabel: "Paused",
        badgeStyle: .pending,
        reason: "Boundary is paused — no rules will activate until you resume.",
        endsSummary: "Tap Resume when you’re ready for automation again.",
        quietModeName: nil
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
