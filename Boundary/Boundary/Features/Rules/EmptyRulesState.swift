//
//  EmptyRulesState.swift
//  Boundary
//

import SwiftUI

/// Rules-specific empty state using shared components; primary path opens the rule builder.
struct EmptyRulesState: View {
    var canAddRule: Bool
    var onAddRule: () -> Void
    var onAddSample: (() -> Void)?

    var body: some View {
        VStack(spacing: BoundaryTheme.Spacing.lg) {
            EmptyStateView(
                systemImage: "slider.horizontal.3",
                title: "No rules yet",
                message: "Create a rule with the builder, or add a sample to explore the app.",
                actionTitle: nil,
                action: nil
            )

            if canAddRule {
                AddRuleButton(title: "Add rule", isEnabled: true, action: onAddRule)

                if let onAddSample {
                    SecondaryButton(
                        title: "Add sample rule",
                        systemImage: "square.stack.3d.up",
                        action: onAddSample
                    )
                }
            }
        }
    }
}

#Preview {
    EmptyRulesState(
        canAddRule: true,
        onAddRule: {},
        onAddSample: {}
    )
}
