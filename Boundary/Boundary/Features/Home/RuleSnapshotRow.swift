//
//  RuleSnapshotRow.swift
//  Boundary
//

import SwiftUI

struct RuleSnapshotRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let rule: BoundaryRule
    var showsDividerBelow: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(rule.name)
                    .font(BoundaryTheme.Typography.headline)
                    .foregroundStyle(.primary)
                Spacer()
                StatusBadge(text: rule.isEnabled ? "On" : "Off", style: rule.isEnabled ? .active : .idle)
            }
            Text(triggerSummary(for: rule.trigger))
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, BoundaryTheme.Spacing.sm)
        .overlay(alignment: .bottom) {
            if showsDividerBelow {
                Divider()
                    .background(BoundaryTheme.Colors.separator(colorScheme))
            }
        }
    }

    private func triggerSummary(for trigger: RuleTrigger) -> String {
        switch trigger {
        case .schedule: "Schedule-based trigger"
        case .calendar: "Calendar keyword trigger"
        case .hybrid: "Schedule + calendar"
        }
    }
}

#Preview {
    let rule = MockData.sampleRuleAfterHours
    return VStack(spacing: 0) {
        RuleSnapshotRow(rule: rule, showsDividerBelow: true)
        RuleSnapshotRow(rule: BoundaryRule(
            name: "Deep work",
            isEnabled: false,
            trigger: .schedule(MockData.businessHoursSchedule),
            quietMode: MockData.quietWork,
            restoreBehavior: .maintain
        ), showsDividerBelow: false)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
