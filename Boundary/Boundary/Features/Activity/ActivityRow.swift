//
//  ActivityRow.swift
//  Boundary
//

import SwiftUI

struct ActivityRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let item: ActivityItem

    var body: some View {
        BoundaryCard {
            HStack(alignment: .top, spacing: BoundaryTheme.Spacing.md) {
                timeColumn

                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(accentLineColor)
                    .frame(width: 3)
                    .padding(.vertical, 2)

                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: item.type.symbolName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(accentLineColor)
                        Text(item.title)
                            .font(BoundaryTheme.Typography.headline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: BoundaryTheme.Spacing.sm)
                        StatusBadge(text: item.type.displayLabel, style: badgeStyle)
                    }

                    if !item.detail.isEmpty {
                        Text(item.detail)
                            .font(BoundaryTheme.Typography.bodySecondary)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let ruleID = item.ruleID {
                        Text("Rule \(ruleID.uuidString.prefix(8))…")
                            .font(BoundaryTheme.Typography.captionSmall)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    private var timeColumn: some View {
        Text(item.timestamp, format: .dateTime.hour().minute())
            .font(.system(.body, design: .rounded).weight(.semibold).monospacedDigit())
            .foregroundStyle(.secondary)
            .frame(minWidth: 56, alignment: .leading)
            .accessibilityLabel(
                item.timestamp.formatted(date: .omitted, time: .shortened)
            )
    }

    private var badgeStyle: StatusBadge.Style {
        switch item.type {
        case .activated: .active
        case .ended: .idle
        case .skipped: .pending
        case .override: .pending
        }
    }

    private var accentLineColor: Color {
        switch item.type {
        case .activated:
            return BoundaryTheme.Colors.statusEmphasis(colorScheme)
        case .ended:
            return Color.secondary.opacity(0.55)
        case .skipped:
            return Color.orange.opacity(colorScheme == .dark ? 0.85 : 0.75)
        case .override:
            return Color.accentColor
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: BoundaryTheme.Spacing.sm) {
            ActivityRow(
                item: ActivityItem(
                    type: .activated,
                    ruleID: UUID(),
                    title: "Boundary on",
                    detail: "Schedule matched · After hours"
                )
            )
            ActivityRow(
                item: ActivityItem(
                    type: .override,
                    title: "Manual override",
                    detail: "Notifications resumed"
                )
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
