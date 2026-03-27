//
//  ActivityView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct ActivityView: View {
    @Environment(ActivityStore.self) private var activityStore
    @Query(sort: \ActivityEvent.occurredAt, order: .reverse) private var events: [ActivityEvent]
    @Bindable var viewModel: ActivityViewModel

    private var groupedEvents: [(day: Date, items: [ActivityEvent])] {
        let cal = Calendar.current
        let byDay = Dictionary(grouping: events) { cal.startOfDay(for: $0.occurredAt) }
        return byDay.keys.sorted(by: >).map { day in
            let items = (byDay[day] ?? []).sorted { $0.occurredAt > $1.occurredAt }
            return (day, items)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    ContentUnavailableView(
                        "No activity yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Boundary will log activations and overrides here.")
                    )
                } else {
                    List {
                        ForEach(groupedEvents, id: \.day) { section in
                            Section {
                                ForEach(section.items) { event in
                                    eventRow(event)
                                }
                            } header: {
                                Text(section.day, format: .dateTime.month(.wide).day().year())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.logSampleEvent(in: activityStore)
                    } label: {
                        Label("Log sample", systemImage: "plus")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func eventRow(_ event: ActivityEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(event.kind.rawValue)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            if !event.detail.isEmpty {
                Text(event.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let ruleID = event.ruleID {
                Text("Rule: \(ruleID.uuidString.prefix(8))…")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Text(event.occurredAt, style: .time)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ActivityView(viewModel: ActivityViewModel(activityLogger: ActivityLogger()))
        .environment(ActivityStore())
        .modelContainer(for: [ActivityEvent.self, AppConfiguration.self], inMemory: true)
}
