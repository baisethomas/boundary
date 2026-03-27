//
//  ModePill.swift
//  Boundary
//

import SwiftUI

/// Compact label for a Focus / quiet mode name (e.g. “Do Not Disturb”).
struct ModePill: View {
    @Environment(\.colorScheme) private var colorScheme

    let text: String

    var body: some View {
        Text(text)
            .font(BoundaryTheme.Typography.captionSmall)
            .padding(.horizontal, BoundaryTheme.Spacing.sm)
            .padding(.vertical, BoundaryTheme.Spacing.xxs + 1)
            .background(
                Capsule()
                    .strokeBorder(BoundaryTheme.Colors.separator(colorScheme), lineWidth: 1)
            )
            .foregroundStyle(.secondary)
    }
}

#Preview {
    HStack {
        ModePill(text: "Do Not Disturb")
        ModePill(text: "Work")
    }
    .padding()
}
