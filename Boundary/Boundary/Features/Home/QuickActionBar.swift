//
//  QuickActionBar.swift
//  Boundary
//

import SwiftUI

struct QuickActionBar: View {
    @Environment(\.colorScheme) private var colorScheme

    var isGloballyPaused: Bool
    var isBusy: Bool
    var onPause: () -> Void
    var onResume: () -> Void
    var onRunTest: () -> Void
    var onCreateRule: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            Text("Quick actions")
                .font(BoundaryTheme.Typography.captionSmall)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.5)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: BoundaryTheme.Spacing.sm),
                    GridItem(.flexible(), spacing: BoundaryTheme.Spacing.sm),
                ],
                spacing: BoundaryTheme.Spacing.sm
            ) {
                if isGloballyPaused {
                    quickTile(
                        title: "Resume",
                        systemImage: "play.fill",
                        accent: true,
                        action: onResume
                    )
                    .disabled(isBusy)
                } else {
                    quickTile(
                        title: "Pause",
                        systemImage: "pause.fill",
                        accent: false,
                        action: onPause
                    )
                    .disabled(isBusy)
                }

                quickTile(
                    title: "Run test",
                    systemImage: "arrow.triangle.2.circlepath",
                    accent: false,
                    action: onRunTest
                )
                .disabled(isBusy)

                quickTile(
                    title: "Create rule",
                    systemImage: "plus.circle.fill",
                    accent: false,
                    action: onCreateRule
                )
            }
        }
    }

    private func quickTile(title: String, systemImage: String, accent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: BoundaryTheme.Spacing.xs) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(accent ? BoundaryTheme.Colors.statusEmphasis(colorScheme) : .primary)
                Text(title)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BoundaryTheme.Spacing.md)
            .padding(.horizontal, BoundaryTheme.Spacing.xs)
            .background {
                RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous)
                    .fill(BoundaryTheme.Colors.cardBackground(colorScheme))
                    .overlay {
                        RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous)
                            .strokeBorder(BoundaryTheme.Colors.separator(colorScheme), lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickActionBar(
        isGloballyPaused: false,
        isBusy: false,
        onPause: {},
        onResume: {},
        onRunTest: {},
        onCreateRule: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
