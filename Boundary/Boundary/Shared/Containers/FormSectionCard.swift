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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                content()
            }
            .clipShape(RoundedRectangle(cornerRadius: BoundaryTheme.cornerRadius, style: .continuous))
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: BoundaryTheme.cornerRadius, style: .continuous))
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
