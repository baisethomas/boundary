//
//  RuleListView.swift
//  Boundary
//

import SwiftUI

/// Active and disabled sections backed by `RulesStore.rules` slices.
struct RuleListView: View {
    let enabledRules: [BoundaryRule]
    let disabledRules: [BoundaryRule]
    let summaryText: String
    let showsEntitlementHint: Bool
    let runStateLine: (BoundaryRule) -> String
    let onToggleEnabled: (BoundaryRule, Bool) -> Void
    let onEdit: (BoundaryRule) -> Void
    let onDelete: (BoundaryRule) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
                Text(summaryText)
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)

                if showsEntitlementHint {
                    Text("Free tier: one rule. Upgrade later for unlimited.")
                        .font(BoundaryTheme.Typography.captionSmall)
                        .foregroundStyle(.tertiary)
                }
            }

            if !enabledRules.isEmpty {
                section(title: "Active", subtitle: "Rules that can trigger Boundary.") {
                    ForEach(enabledRules) { rule in
                        RuleRowCard(
                            rule: rule,
                            runStateLine: runStateLine(rule),
                            onSetEnabled: { onToggleEnabled(rule, $0) },
                            onEdit: { onEdit(rule) },
                            onDelete: { onDelete(rule) }
                        )
                    }
                }
            }

            if !disabledRules.isEmpty {
                section(title: "Disabled", subtitle: "Turned off — they won’t run until enabled.") {
                    ForEach(disabledRules) { rule in
                        RuleRowCard(
                            rule: rule,
                            runStateLine: runStateLine(rule),
                            onSetEnabled: { onToggleEnabled(rule, $0) },
                            onEdit: { onEdit(rule) },
                            onDelete: { onDelete(rule) }
                        )
                    }
                }
            }
        }
    }

    private func section<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                Text(title)
                    .font(BoundaryTheme.Typography.sectionTitle)
                Text(subtitle)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.tertiary)
            }
            VStack(spacing: BoundaryTheme.Spacing.sm) {
                content()
            }
        }
    }
}

#Preview {
    let enabled = [MockData.sampleRuleAfterHours]
    let disabled = [
        BoundaryRule(
            name: "Deep work",
            isEnabled: false,
            trigger: .schedule(MockData.businessHoursSchedule),
            quietMode: MockData.quietWork,
            restoreBehavior: .maintain
        ),
    ]
    return ScrollView {
        RuleListView(
            enabledRules: enabled,
            disabledRules: disabled,
            summaryText: "Active: After hours",
            showsEntitlementHint: true,
            runStateLine: { _ in "Waiting for trigger" },
            onToggleEnabled: { _, _ in },
            onEdit: { _ in },
            onDelete: { _ in }
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
