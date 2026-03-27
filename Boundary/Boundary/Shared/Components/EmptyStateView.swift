//
//  EmptyStateView.swift
//  Boundary
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let message {
                Text(message)
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        } actions: {
            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, BoundaryTheme.Spacing.xl)
                    .padding(.top, BoundaryTheme.Spacing.sm)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        systemImage: "slider.horizontal.3",
        title: "No rules yet",
        message: "Add a rule to automate quiet time from your schedule or calendar.",
        actionTitle: "Add rule",
        action: {}
    )
}
