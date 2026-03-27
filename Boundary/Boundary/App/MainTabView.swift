//
//  MainTabView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct MainTabView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppRouter.self) private var router

    var body: some View {
        TabView(
            selection: Binding(
                get: { router.selectedTab },
                set: { router.selectedTab = $0 }
            )
        ) {
            HomeView(
                viewModel: HomeViewModel(
                    calendarService: services.calendarService,
                    evaluationCoordinator: services.evaluationCoordinator
                )
            )
            .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.systemImage) }
            .tag(AppTab.home)

            RulesView(
                viewModel: RulesViewModel(ruleEngine: services.ruleEngine)
            )
            .tabItem { Label(AppTab.rules.title, systemImage: AppTab.rules.systemImage) }
            .tag(AppTab.rules)

            ActivityView(
                viewModel: ActivityViewModel(activityLogger: services.activityLogger)
            )
            .tabItem { Label(AppTab.activity.title, systemImage: AppTab.activity.systemImage) }
            .tag(AppTab.activity)

            SettingsView(
                viewModel: SettingsViewModel()
            )
            .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
            .tag(AppTab.settings)
        }
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    MainTabView()
        .environment(AppRouter())
        .environment(deps.appState)
        .environment(deps.rulesStore)
        .environment(deps.activityStore)
        .environment(deps.permissionsManager)
        .environment(deps.services)
        .modelContainer(PreviewPersistence.inMemoryContainer())
}
