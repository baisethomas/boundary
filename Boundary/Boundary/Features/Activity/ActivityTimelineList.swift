//
//  ActivityTimelineList.swift
//  Boundary
//

import SwiftUI

/// Date-grouped sections of `ActivityRow`s (newest days first, newest items first within a day).
struct ActivityTimelineList: View {
    let sections: [(day: Date, items: [ActivityItem])]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xl) {
            ForEach(sections, id: \.day) { section in
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                    Text(section.day, format: .dateTime.weekday(.wide).month(.abbreviated).day().year())
                        .font(BoundaryTheme.Typography.captionSmall.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.4)

                    VStack(spacing: BoundaryTheme.Spacing.sm) {
                        ForEach(section.items) { item in
                            ActivityRow(item: item)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let cal = Calendar.current
    let today = cal.startOfDay(for: .now)
    let items: [ActivityItem] = [
        ActivityItem(timestamp: .now, type: .activated, title: "On", detail: "Test"),
        ActivityItem(
            timestamp: cal.date(byAdding: .hour, value: -2, to: .now) ?? .now,
            type: .ended,
            title: "Off",
            detail: ""
        ),
    ]
    let sections: [(Date, [ActivityItem])] = [(today, items)]
    return ScrollView {
        ActivityTimelineList(sections: sections)
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
