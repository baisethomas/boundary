//
//  TriggerTypePicker.swift
//  Boundary
//

import SwiftUI

struct TriggerTypePicker: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var selection: RuleBuilderTriggerKind

    var body: some View {
        VStack(spacing: BoundaryTheme.Spacing.sm) {
            ForEach(RuleBuilderTriggerKind.allCases) { kind in
                Button {
                    selection = kind
                } label: {
                    HStack(alignment: .top, spacing: BoundaryTheme.Spacing.md) {
                        Image(systemName: icon(for: kind))
                            .font(.title2)
                            .foregroundStyle(selection == kind ? Color.accentColor : .secondary)
                            .frame(width: 36, alignment: .center)
                        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                            Text(kind.displayName)
                                .font(BoundaryTheme.Typography.headline)
                                .foregroundStyle(.primary)
                            Text(kind.subtitle)
                                .font(BoundaryTheme.Typography.bodySecondary)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                        if selection == kind {
                            Image(systemName: "checkmark.circle.fill")
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
                                selection == kind
                                    ? Color.accentColor.opacity(0.45)
                                    : BoundaryTheme.Colors.separator(colorScheme),
                                lineWidth: selection == kind ? 2 : 0.5
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func icon(for kind: RuleBuilderTriggerKind) -> String {
        switch kind {
        case .schedule: "calendar.day.timeline.left"
        case .calendar: "calendar.badge.clock"
        case .hybrid: "arrow.triangle.merge"
        }
    }
}

#Preview {
    struct Host: View {
        @State private var k = RuleBuilderTriggerKind.schedule
        var body: some View {
            TriggerTypePicker(selection: $k)
                .padding()
        }
    }
    return Host()
}
