//
//  HomeView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    @Bindable var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "Now", subtitle: "Boundary state from rule engine")

                    BoundaryCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(headlineTitle)
                                    .font(.title2.weight(.bold))
                                Spacer()
                                StatusBadge(
                                    text: statusBadgeText,
                                    style: statusBadgeStyle
                                )
                            }
                            Text(appState.lastEvaluation?.reason ?? "Not evaluated yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    BoundaryCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Next boundary")
                                .font(.headline)
                            Text(appState.lastEvaluation?.nextBoundarySummary ?? "—")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    BoundaryCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calendar")
                                .font(.headline)
                            Text("Access: \(viewModel.calendarState.rawValue) (EventKit placeholder)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .boundaryScreenPadding()
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .task {
                await viewModel.loadCalendarState()
            }
        }
    }

    private var headlineTitle: String {
        if appState.currentBoundaryState == .paused {
            return "Paused"
        }
        return appState.lastEvaluation?.activeRuleTitle ?? "No active boundary"
    }

    private var statusBadgeText: String {
        switch appState.currentBoundaryState {
        case .paused: "Paused"
        case .inactive: "Off"
        case .active: "Quiet"
        }
    }

    private var statusBadgeStyle: StatusBadge.Style {
        switch appState.currentBoundaryState {
        case .active: .active
        case .inactive: .idle
        case .paused: .pending
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(calendarService: CalendarService()))
        .environment(AppState())
        .modelContainer(for: [PersistedRule.self, ActivityEvent.self, AppConfiguration.self], inMemory: true)
}
