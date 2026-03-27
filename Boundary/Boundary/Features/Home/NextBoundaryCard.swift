//
//  NextBoundaryCard.swift
//  Boundary
//

import SwiftUI

struct NextBoundaryCard: View {
    let summary: String
    var detail: String?
    var nextDate: Date?

    var body: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                HStack {
                    Text("Next boundary")
                        .font(BoundaryTheme.Typography.headline)
                    Spacer()
                    Image(systemName: "arrow.forward.circle")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }

                Text(summary)
                    .font(BoundaryTheme.Typography.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(BoundaryTheme.Typography.bodySecondary)
                        .foregroundStyle(.secondary)
                }

                if let nextDate {
                    Text(nextDate, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute())
                        .font(BoundaryTheme.Typography.captionSmall)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: BoundaryTheme.Spacing.md) {
        NextBoundaryCard(
            summary: "After Hours",
            detail: "Evening quiet kicks in after your workday window.",
            nextDate: .now.addingTimeInterval(3600 * 4)
        )
        NextBoundaryCard(summary: "No upcoming boundary", detail: "Add a rule or enable an existing one.", nextDate: nil)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
