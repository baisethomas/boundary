//
//  BoundaryTheme.swift
//  Boundary
//
//  Calm, minimal, premium — spacing, radius, type, and semantic colors (light/dark aware).
//

import SwiftUI

enum BoundaryTheme {

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        /// Standard horizontal inset for screen content.
        static let screenHorizontal: CGFloat = 20
        static let cardPadding: CGFloat = md
    }

    // MARK: - Corner radius

    enum Radius {
        static let card: CGFloat = 12
        static let button: CGFloat = 12
        static let pill: CGFloat = 100
        static let small: CGFloat = 8
    }

    // MARK: - Typography

    enum Typography {
        static let screenTitle: Font = .largeTitle.weight(.semibold)
        static let sectionTitle: Font = .title3.weight(.semibold)
        static let headline: Font = .headline
        static let body: Font = .body
        static let bodySecondary: Font = .subheadline
        static let caption: Font = .caption.weight(.medium)
        static let captionSmall: Font = .caption2.weight(.medium)
    }

    // MARK: - Semantic colors (use with `colorScheme` from environment)

    enum Colors {
        static func screenBackground(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(.systemBackground) : Color(.systemGroupedBackground)
        }

        static func cardBackground(_ scheme: ColorScheme) -> Color {
            Color(.secondarySystemGroupedBackground)
        }

        static func elevatedSurface(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(white: 0.14) : Color(white: 1.0)
        }

        /// Hairline separator / outline.
        static func separator(_ scheme: ColorScheme) -> Color {
            Color.primary.opacity(scheme == .dark ? 0.12 : 0.08)
        }

        /// Muted positive state (quiet on) — restrained, not “success green”.
        static func statusEmphasis(_ scheme: ColorScheme) -> Color {
            scheme == .dark
                ? Color(red: 0.45, green: 0.72, blue: 0.62)
                : Color(red: 0.18, green: 0.42, blue: 0.38)
        }

        static func statusEmphasisBackground(_ scheme: ColorScheme) -> Color {
            statusEmphasis(scheme).opacity(scheme == .dark ? 0.18 : 0.12)
        }

        static func statusNeutralBackground(_ scheme: ColorScheme) -> Color {
            Color(.tertiarySystemFill)
        }

        static func statusPendingBackground(_ scheme: ColorScheme) -> Color {
            Color.primary.opacity(scheme == .dark ? 0.14 : 0.06)
        }
    }
}
