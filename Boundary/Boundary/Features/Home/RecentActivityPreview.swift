//
//  RecentActivityPreview.swift
//  Boundary
//

import SwiftUI

struct RecentActivityPreview: View {
    @Environment(\.colorScheme) private var colorScheme

    let items: [ActivityItem]
    var onSeeAll: () -> Void

    private var previewItems: [ActivityItem] {
        Array(items.prefix(3))
    }

    var body: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                HStack {
                    Text("Recent activity")
                        .font(BoundaryTheme.Typography.headline)
                    Spacer()
                    Button("See all", action: onSeeAll)
                        .font(BoundaryTheme.Typography.caption)
                        .foregroundStyle(BoundaryTheme.Colors.statusEmphasis(colorScheme))
                }

                if previewItems.isEmpty {
                    Text("No events yet — when Boundary activates or you override, it shows up here.")
                        .font(BoundaryTheme.Typography.bodySecondary)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, BoundaryTheme.Spacing.xs)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(previewItems.enumerated()), id: \.element.id) { index, item in
                            activityRow(item)
                            if index < previewItems.count - 1 {
                                Divider()
                                    .opacity(0.35)
                                    .padding(.vertical, BoundaryTheme.Spacing.xs)
                            }
                        }
                    }
                }
            }
        }
    }

    private func activityRow(_ item: ActivityItem) -> some View {
        HStack(alignment: .top, spacing: BoundaryTheme.Spacing.sm) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(BoundaryTheme.Colors.statusNeutralBackground(colorScheme))
                .frame(width: 4)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                HStack {
                    Text(item.title)
                        .font(BoundaryTheme.Typography.body.weight(.medium))
                    Spacer()
                    Text(item.type.rawValue.capitalized)
                        .font(BoundaryTheme.Typography.captionSmall)
                        .foregroundStyle(.tertiary)
                }
                if !item.detail.isEmpty {
                    Text(item.detail)
                        .font(BoundaryTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Text(item.timestamp, style: .relative)
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, BoundaryTheme.Spacing.xxs)
    }
}

#Preview {
    RecentActivityPreview(items: MockData.sampleActivityItems, onSeeAll: {})
        .padding()
        .background(Color(.systemGroupedBackground))
}
