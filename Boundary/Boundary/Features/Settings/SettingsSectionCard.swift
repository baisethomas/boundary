//
//  SettingsSectionCard.swift
//  Boundary
//

import SwiftUI

/// Grouped settings surface using the shared card treatment.
struct SettingsSectionCard<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder private var content: () -> Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                Text(title)
                    .font(BoundaryTheme.Typography.sectionTitle)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(BoundaryTheme.Typography.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            BoundaryCard {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
            }
        }
    }
}

#Preview {
    SettingsSectionCard(title: "Example", subtitle: "Optional subtitle") {
        Text("Inner content")
            .padding(.vertical, BoundaryTheme.Spacing.sm)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
