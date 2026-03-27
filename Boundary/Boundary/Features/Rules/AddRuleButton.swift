//
//  AddRuleButton.swift
//  Boundary
//

import SwiftUI

/// Primary add affordance for the Rules screen (toolbar or inline).
struct AddRuleButton: View {
    var title: String = "Add rule"
    var systemImage: String = "plus.circle.fill"
    var isEnabled: Bool
    let action: () -> Void

    var body: some View {
        PrimaryButton(title: title, systemImage: systemImage, action: action)
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.45)
    }
}

#Preview {
    VStack(spacing: BoundaryTheme.Spacing.md) {
        AddRuleButton(isEnabled: true, action: {})
        AddRuleButton(title: "Add sample rule", isEnabled: false, action: {})
    }
    .padding()
}
