//
//  InlineActionRow.swift
//  Boundary
//

import SwiftUI

/// Tappable row: optional leading icon, title + optional subtitle, trailing chevron.
struct InlineActionRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    var subtitle: String?
    var systemImage: String?
    /// When `true`, draws a subtle bottom separator (useful stacked outside `List`).
    var showsDivider: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: BoundaryTheme.Spacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .center)
                }
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                    Text(title)
                        .font(BoundaryTheme.Typography.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    if let subtitle {
                        Text(subtitle)
                            .font(BoundaryTheme.Typography.bodySecondary)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, BoundaryTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Divider()
                    .background(BoundaryTheme.Colors.separator(colorScheme))
            }
        }
    }
}

#Preview {
    List {
        InlineActionRow(title: "Calendar access", subtitle: "Required for OOO matching", systemImage: "calendar") {}
        InlineActionRow(title: "Notifications", systemImage: "bell.badge") {}
    }
    .listStyle(.plain)
}
