//
//  StatusBadge.swift
//  Boundary
//

import SwiftUI

struct StatusBadge: View {
    enum Style {
        case active
        case idle
        case pending
    }

    @Environment(\.colorScheme) private var colorScheme

    let text: String
    var style: Style = .idle

    var body: some View {
        Text(text)
            .font(BoundaryTheme.Typography.captionSmall)
            .padding(.horizontal, BoundaryTheme.Spacing.sm)
            .padding(.vertical, BoundaryTheme.Spacing.xxs + 2)
            .background(background, in: Capsule())
            .foregroundStyle(foreground)
    }

    private var background: Color {
        switch style {
        case .active:
            BoundaryTheme.Colors.statusEmphasisBackground(colorScheme)
        case .idle:
            BoundaryTheme.Colors.statusNeutralBackground(colorScheme)
        case .pending:
            BoundaryTheme.Colors.statusPendingBackground(colorScheme)
        }
    }

    private var foreground: Color {
        switch style {
        case .active:
            BoundaryTheme.Colors.statusEmphasis(colorScheme)
        case .idle:
            Color.secondary
        case .pending:
            Color.primary.opacity(colorScheme == .dark ? 0.85 : 0.75)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
        StatusBadge(text: "Quiet", style: .active)
        StatusBadge(text: "Off", style: .idle)
        StatusBadge(text: "Paused", style: .pending)
    }
    .padding()
}

#Preview("Dark") {
    VStack(spacing: BoundaryTheme.Spacing.sm) {
        StatusBadge(text: "Quiet", style: .active)
        StatusBadge(text: "Off", style: .idle)
    }
    .padding()
    .preferredColorScheme(.dark)
}
