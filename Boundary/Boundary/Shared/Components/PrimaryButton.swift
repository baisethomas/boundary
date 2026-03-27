//
//  PrimaryButton.swift
//  Boundary
//

import SwiftUI

struct PrimaryButton: View {
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
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: BoundaryTheme.Radius.button))
        .controlSize(.large)
    }
}

#Preview {
    VStack(spacing: BoundaryTheme.Spacing.md) {
        PrimaryButton(title: "Continue", systemImage: "arrow.right") {}
        PrimaryButton(title: "Save") {}
    }
    .padding()
}
