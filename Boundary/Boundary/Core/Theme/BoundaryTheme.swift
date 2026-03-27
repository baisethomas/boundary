//
//  BoundaryTheme.swift
//  Boundary
//

import SwiftUI

enum BoundaryTheme {
    static let cornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16

    static let accent = Color.accentColor

    static func groupedBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemGroupedBackground)
    }
}
