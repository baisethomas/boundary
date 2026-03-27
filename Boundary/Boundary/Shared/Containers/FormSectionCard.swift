//
//  FormSectionCard.swift
//  Boundary
//

import SwiftUI

/// Groups form-style rows inside a card for Settings and editors.
struct FormSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            Text(title)
                .font(BoundaryTheme.Typography.caption)
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                content()
            }
            .clipShape(RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous))
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous))
        }
    }
}

#Preview {
    FormSectionCard(title: "Account") {
        Text("Row")
            .padding()
    }
    .padding()
}
