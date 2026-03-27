//
//  BoundaryCard.swift
//  Boundary
//

import SwiftUI

struct BoundaryCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(BoundaryTheme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BoundaryTheme.cornerRadius, style: .continuous))
    }
}

#Preview {
    BoundaryCard {
        Text("Card content")
    }
    .padding()
}
