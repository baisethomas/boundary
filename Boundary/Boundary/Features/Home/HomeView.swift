//
//  HomeView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(RulesStore.self) private var rulesStore
    @Environment(ActivityStore.self) private var activityStore
    @Environment(ServiceContainer.self) private var services
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" })
    private var configurations: [AppConfiguration]

    @Bindable var viewModel: HomeViewModel

    private var configuration: AppConfiguration? { configurations.first }

    private var ruleRows: [BoundaryRule] {
        Array(rulesStore.rules.prefix(4))
    }

    private var activeQuietModeName: String? {
        guard let evaluation = appState.lastEvaluation else { return nil }
        switch evaluation.boundaryState {
        case let .active(ruleId):
            return rulesStore.rules.first(where: { $0.id == ruleId })?.quietMode.displayName
        case .inactive, .paused:
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                BoundaryScreen {
                    VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
                        SectionHeader(
                            title: "Dashboard",
                            subtitle: "Current state, what’s next, and shortcuts."
                        )

                        CurrentStateHeroCard(
                            headline: viewModel.heroHeadline(appState: appState),
                            modeLabel: viewModel.modeLabel(appState: appState),
                            badgeStyle: viewModel.modeBadgeStyle(appState: appState),
                            reason: viewModel.reasonLine(appState: appState),
                            endsSummary: viewModel.endsSummary(appState: appState),
                            quietModeName: activeQuietModeName
                        )

                        NextBoundaryCard(
                            summary: viewModel.nextBoundarySummary(appState: appState),
                            detail: viewModel.nextBoundaryDetail(appState: appState),
                            nextDate: appState.lastEvaluation?.nextTriggerDate
                        )

                        QuickActionBar(
                            isGloballyPaused: appState.isPaused,
                            isBusy: viewModel.isRefreshing,
                            onPause: { setGlobalPaused(true) },
                            onResume: { setGlobalPaused(false) },
                            onRunTest: { runTestEvaluation() },
                            onCreateRule: { router.selectedTab = .rules }
                        )

                        calendarStatusCard

                        rulesSnapshotSection

                        RecentActivityPreview(items: activityStore.activities) {
                            router.selectedTab = .activity
                        }
                    }
                }
                .navigationTitle("Home")
                .task {
                    await viewModel.loadCalendarState()
                    appState.syncCalendarPermission(viewModel.calendarState)
                }

                if let toast = viewModel.toast {
                    Text(toast)
                        .font(BoundaryTheme.Typography.caption)
                        .padding(.horizontal, BoundaryTheme.Spacing.md)
                        .padding(.vertical, BoundaryTheme.Spacing.sm)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, BoundaryTheme.Spacing.lg)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(duration: 0.35), value: viewModel.toast)
                }
            }
        }
    }

    @ViewBuilder
    private var calendarStatusCard: some View {
        BoundaryCard {
            HStack(spacing: BoundaryTheme.Spacing.md) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 36, alignment: .center)
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                    Text("Calendar access")
                        .font(BoundaryTheme.Typography.headline)
                    Text(statusLine(for: appState.calendarPermission))
                        .font(BoundaryTheme.Typography.bodySecondary)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private var rulesSnapshotSection: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            Text("Your rules")
                .font(BoundaryTheme.Typography.captionSmall)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.5)

            if rulesStore.rules.isEmpty {
                BoundaryCard {
                    Text("No rules yet. Create one to see it here.")
                        .font(BoundaryTheme.Typography.bodySecondary)
                        .foregroundStyle(.secondary)
                }
            } else {
                BoundaryCard {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(ruleRows.enumerated()), id: \.element.id) { index, rule in
                            RuleSnapshotRow(
                                rule: rule,
                                showsDividerBelow: index < ruleRows.count - 1
                            )
                        }
                        if rulesStore.rules.count > ruleRows.count {
                            Text("+ \(rulesStore.rules.count - ruleRows.count) more in Rules")
                                .font(BoundaryTheme.Typography.captionSmall)
                                .foregroundStyle(.tertiary)
                                .padding(.top, BoundaryTheme.Spacing.xs)
                        }
                    }
                }
            }
        }
    }

    private func statusLine(for state: CalendarAuthorizationState) -> String {
        switch state {
        case .authorized:
            return "Granted — calendar-aware rules can run."
        case .denied, .restricted:
            return "Limited — open Settings to allow Calendar when you’re ready."
        case .notDetermined:
            return "Not requested yet — onboarding or Settings can enable access."
        case .mock:
            return "Preview mock — production uses your real calendar permission state."
        }
    }

    private func setGlobalPaused(_ paused: Bool) {
        guard let config = configuration else { return }
        config.isPaused = paused
        try? modelContext.save()
        appState.syncConfiguration(config)
    }

    private func runTestEvaluation() {
        Task {
            let rules = (try? rulesStore.persistedRules()) ?? []
            await viewModel.runForegroundEvaluation(
                appState: appState,
                configuration: configuration,
                rules: rules,
                activityStore: activityStore,
                trigger: .manual
            )
            await viewModel.showToast("Boundary refreshed")
        }
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    HomeView(
        viewModel: HomeViewModel(
            calendarService: deps.services.calendarService,
            evaluationCoordinator: deps.services.evaluationCoordinator
        )
    )
    .environment(deps.appState)
    .environment(deps.rulesStore)
    .environment(deps.activityStore)
    .environment(deps.services)
    .environment(AppRouter())
    .modelContainer(for: [PersistedRule.self, ActivityEvent.self, AppConfiguration.self], inMemory: true)
}
