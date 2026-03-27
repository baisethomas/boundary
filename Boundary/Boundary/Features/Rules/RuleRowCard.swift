//
//  RuleRowCard.swift
//  Boundary
//

import SwiftUI

/// Single rule row: metadata, run state, enable toggle, and placeholder edit/delete.
struct RuleRowCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let rule: BoundaryRule
    let runStateLine: String
    let onSetEnabled: (Bool) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                        Text(rule.name)
                            .font(BoundaryTheme.Typography.headline)
                            .foregroundStyle(.primary)
                        Text(RulesPresentation.triggerSummary(for: rule.trigger))
                            .font(BoundaryTheme.Typography.bodySecondary)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: BoundaryTheme.Spacing.sm)
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { rule.isEnabled },
                            set: { onSetEnabled($0) }
                        )
                    )
                    .labelsHidden()
                    .tint(BoundaryTheme.Colors.statusEmphasis(colorScheme))
                }

                HStack(spacing: BoundaryTheme.Spacing.xs) {
                    ModePill(text: rule.quietMode.modeType.displayName)
                    Text(rule.quietMode.displayName)
                        .font(BoundaryTheme.Typography.captionSmall)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                HStack(alignment: .center) {
                    StatusBadge(text: rule.isEnabled ? "Enabled" : "Disabled", style: rule.isEnabled ? .active : .idle)
                    Spacer(minLength: BoundaryTheme.Spacing.sm)
                    Text(runStateLine)
                        .font(BoundaryTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Spacer()
                    Menu {
                        Button("Edit rule…", systemImage: "pencil") {
                            onEdit()
                        }
                        Divider()
                        Button("Delete rule…", systemImage: "trash", role: .destructive) {
                            onDelete()
                        }
                    } label: {
                        Label("Rule actions", systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Rule actions")
                }
            }
        }
    }
}

// MARK: - Shared copy for triggers (extend here when rule builder ships)

enum RulesPresentation {
    static func triggerSummary(for trigger: RuleTrigger) -> String {
        switch trigger {
        case .schedule:
            return "Schedule — quiet during your chosen days and hours."
        case .calendar:
            return "Calendar — matches events by keywords and types."
        case .hybrid:
            return "Hybrid — schedule window plus calendar signals."
        }
    }
}

#Preview {
    ScrollView {
        RuleRowCard(
            rule: MockData.sampleRuleAfterHours,
            runStateLine: "Active now",
            onSetEnabled: { _ in },
            onEdit: {},
            onDelete: {}
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
