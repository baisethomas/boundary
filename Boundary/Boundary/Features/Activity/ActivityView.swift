//
//  ActivityView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct ActivityView: View {
    @Environment(ActivityStore.self) private var activityStore
    @Bindable var viewModel: ActivityViewModel

    private var sections: [(day: Date, items: [ActivityItem])] {
        viewModel.dayGroupedSections(from: activityStore.activities)
    }

    private var hasAnyActivity: Bool {
        !activityStore.activities.isEmpty
    }

    private var hasVisibleActivity: Bool {
        !sections.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if !hasAnyActivity {
                    BoundaryScreen {
                        VStack(spacing: BoundaryTheme.Spacing.xl) {
                            SectionHeader(
                                title: "Activity",
                                subtitle: "A clear history of when Boundary runs — builds trust over time."
                            )
                            EmptyStateView(
                                systemImage: "clock.arrow.circlepath",
                                title: "No activity yet",
                                message: "Activations, endings, skips, and manual overrides will appear here.",
                                actionTitle: "Log sample",
                                action: { viewModel.logSampleEvent(in: activityStore) }
                            )
                        }
                    }
                } else {
                    BoundaryScreen {
                        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                            SectionHeader(
                                title: "Activity",
                                subtitle: "Grouped by day. Filter to focus on one kind of event."
                            )

                            ActivityFilterBar(selection: $viewModel.filter)

                            if hasVisibleActivity {
                                ActivityTimelineList(sections: sections)
                            } else {
                                filteredEmptyState
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

    private var filteredEmptyState: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                Text("Nothing for this filter")
                    .font(BoundaryTheme.Typography.headline)
                Text("Try “All” or pick another category. Events stay in the log — they’re only hidden while filtering.")
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)
                Button("Show all activity") {
                    viewModel.filter = .all
                }
                .font(BoundaryTheme.Typography.caption.weight(.semibold))
                .padding(.top, BoundaryTheme.Spacing.xs)
            }
        }
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    ActivityView(viewModel: ActivityViewModel(activityLogger: deps.services.activityLogger))
        .environment(deps.activityStore)
        .modelContainer(for: [ActivityEvent.self, AppConfiguration.self], inMemory: true)
}
