//
//  BoundaryApp.swift
//  Boundary
//

import SwiftData
import SwiftUI

@main
struct BoundaryApp: App {
    @State private var dependencies = BoundaryDependencies()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies.appState)
                .environment(dependencies.rulesStore)
                .environment(dependencies.activityStore)
                .environment(dependencies.permissionsManager)
                .environment(dependencies.services)
        }
        .modelContainer(SwiftDataPersistenceService.makeModelContainer())
    }
}
