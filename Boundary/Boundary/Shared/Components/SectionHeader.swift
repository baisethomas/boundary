//
//  SectionHeader.swift
//  Boundary
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var spacing: CGFloat = BoundaryTheme.Spacing.xs

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(title)
                .font(BoundaryTheme.Typography.sectionTitle)
                .foregroundStyle(.primary)
            if let subtitle {
                Text(subtitle)
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
        SectionHeader(title: "Rules", subtitle: "Automate quiet time from your calendar.")
        SectionHeader(title: "No subtitle")
    }
    .padding()
}
