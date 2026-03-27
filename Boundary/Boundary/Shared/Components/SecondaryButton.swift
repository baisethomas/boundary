//
//  SecondaryButton.swift
//  Boundary
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(BoundaryTheme.Typography.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BoundaryTheme.Spacing.sm + 2)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: BoundaryTheme.Radius.button))
        .tint(.primary)
        .controlSize(.large)
    }
}

#Preview {
    VStack(spacing: BoundaryTheme.Spacing.md) {
        SecondaryButton(title: "Not now", systemImage: "xmark") {}
        SecondaryButton(title: "Learn more") {}
    }
    .padding()
}
