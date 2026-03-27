//
//  BoundaryCard.swift
//  Boundary
//

import SwiftUI

struct BoundaryCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    private var elevated: Bool
    @ViewBuilder private var content: () -> Content

    init(elevated: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.elevated = elevated
        self.content = content
    }

    var body: some View {
        content()
            .padding(BoundaryTheme.Spacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous)
                    .fill(fill)
                    .overlay {
                        RoundedRectangle(cornerRadius: BoundaryTheme.Radius.card, style: .continuous)
                            .strokeBorder(BoundaryTheme.Colors.separator(colorScheme), lineWidth: 0.5)
                    }
            }
    }

    private var fill: Color {
        elevated
            ? BoundaryTheme.Colors.elevatedSurface(colorScheme)
            : BoundaryTheme.Colors.cardBackground(colorScheme)
    }
}

#Preview {
    VStack(spacing: BoundaryTheme.Spacing.md) {
        BoundaryCard { Text("Default card") }
        BoundaryCard(elevated: true) { Text("Elevated card") }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
