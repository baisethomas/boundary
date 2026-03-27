//
//  RootView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ServiceContainer.self) private var services

    @Query(filter: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" })
    private var configurations: [AppConfiguration]

    @Query(sort: \PersistedRule.createdAt, order: .reverse)
    private var allRules: [PersistedRule]

    @State private var router = AppRouter()
    @State private var appState = AppState()
    @State private var rulesStore = RulesStore()
    @State private var activityStore = ActivityStore()

    private var configuration: AppConfiguration? { configurations.first }

    var body: some View {
        Group {
            if let configuration {
                if configuration.hasCompletedOnboarding {
                    MainTabView()
                        .environment(router)
                        .environment(appState)
                        .environment(rulesStore)
                        .environment(activityStore)
                } else {
                    OnboardingView(
                        viewModel: OnboardingViewModel(
                            configuration: configuration,
                            permissionsManager: services.permissionsManager
                        )
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
            appState.configuration = configuration
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, configuration?.hasCompletedOnboarding == true else { return }
            Task { await runForegroundEvaluation() }
        }
        .onChange(of: allRules.count) { _, _ in
            guard configuration?.hasCompletedOnboarding == true else { return }
            Task { await runForegroundEvaluation() }
        }
        .onChange(of: configurations.first?.isPaused) { _, _ in
            guard configuration?.hasCompletedOnboarding == true else { return }
            Task { await runForegroundEvaluation() }
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
        appState.configuration = configuration
    }

    @MainActor
    private func runForegroundEvaluation() async {
        await services.evaluationCoordinator.evaluateForeground(
            rules: allRules,
            appState: appState,
            configuration: configuration
        )
    }
}

#Preview {
    RootView()
        .modelContainer(for: [AppConfiguration.self, PersistedRule.self, ActivityEvent.self], inMemory: true)
        .environment(ServiceContainer.preview)
}
