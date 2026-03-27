//
//  View+Boundary.swift
//  Boundary
//

import SwiftUI

extension View {
    /// Horizontal inset aligned with `BoundaryScreen` and `BoundaryTheme.Spacing.screenHorizontal`.
    func boundaryScreenPadding() -> some View {
        padding(.horizontal, BoundaryTheme.Spacing.screenHorizontal)
    }
}
