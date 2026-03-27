//
//  HelpLinkRow.swift
//  Boundary
//

import SwiftUI

/// Single tappable row that opens a URL (placeholder hosts until production links exist).
struct HelpLinkRow: View {
    let title: String
    var subtitle: String?
    let url: URL
    var systemImage: String = "arrow.up.right.square"

    var body: some View {
        Link(destination: url) {
            HStack(alignment: .center, spacing: BoundaryTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                    Text(title)
                        .font(BoundaryTheme.Typography.body.weight(.medium))
                        .foregroundStyle(.primary)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(BoundaryTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: systemImage)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, BoundaryTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 0) {
        HelpLinkRow(
            title: "Help center",
            subtitle: "Placeholder link",
            url: URL(string: "https://example.com/help")!
        )
        Divider()
        HelpLinkRow(
            title: "Privacy",
            subtitle: "Placeholder policy",
            url: URL(string: "https://example.com/privacy")!,
            systemImage: "hand.raised.fill"
        )
    }
    .padding()
}
