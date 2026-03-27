//
//  RootView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppState.self) private var appState
    @Environment(RulesStore.self) private var rulesStore
    @Environment(ActivityStore.self) private var activityStore
    @Environment(PermissionsManager.self) private var permissionsManager
    @Environment(ServiceContainer.self) private var services

    @Query(filter: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" })
    private var configurations: [AppConfiguration]

    @State private var router = AppRouter()

    private var configuration: AppConfiguration? { configurations.first }

    var body: some View {
        Group {
            if let configuration {
                if configuration.hasCompletedOnboarding {
                    MainTabView()
                        .environment(router)
                } else {
                    OnboardingView(
                        viewModel: OnboardingViewModel(configuration: configuration)
                    )
                }
            } else {
                ProgressView("Loading…")
                    .task { await bootstrapIfNeeded() }
            }
        }
        .onAppear {
            bindStoresAndSyncState()
        }
        .onChange(of: configurations.count) { _, _ in
            appState.syncConfiguration(configuration)
        }
        .onChange(of: configurations.first?.hasCompletedOnboarding) { _, _ in
            appState.syncConfiguration(configuration)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, configuration?.hasCompletedOnboarding == true else { return }
            Task { await runForegroundEvaluation() }
        }
        .onChange(of: rulesStore.rules.count) { _, _ in
            guard configuration?.hasCompletedOnboarding == true else { return }
            Task { await runForegroundEvaluation() }
        }
        .onChange(of: configurations.first?.isPaused) { _, _ in
            guard configuration?.hasCompletedOnboarding == true else { return }
            Task { await runForegroundEvaluation() }
        }
        .task {
            await permissionsManager.refreshStatus()
            appState.syncCalendarPermission(permissionsManager.permissionStatus.calendar)
        }
    }

    @MainActor
    private func bootstrapIfNeeded() async {
        services.persistence.ensureSingletonConfiguration(in: modelContext)
        bindStoresAndSyncState()
    }

    private func bindStoresAndSyncState() {
        rulesStore.bind(modelContext)
        activityStore.bind(modelContext)
        appState.syncConfiguration(configuration)
    }

    @MainActor
    private func runForegroundEvaluation() async {
        let persisted = (try? rulesStore.persistedRules()) ?? []
        await services.evaluationCoordinator.evaluateForeground(
            rules: persisted,
            appState: appState,
            configuration: configuration
        )
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    return RootView()
        .modelContainer(for: [AppConfiguration.self, PersistedRule.self, ActivityEvent.self], inMemory: true)
        .environment(deps.appState)
        .environment(deps.rulesStore)
        .environment(deps.activityStore)
        .environment(deps.permissionsManager)
        .environment(deps.services)
}
