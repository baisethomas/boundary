//
//  BoundaryApp.swift
//  Boundary
//

import SwiftData
import SwiftUI

@main
struct BoundaryApp: App {
    /// One container for the lifetime of the process — avoids recreating the store on each body evaluation.
    private let modelContainer: ModelContainer
    @State private var dependencies = BoundaryDependencies()

    init() {
        modelContainer = SwiftDataPersistenceService.makeModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies.appState)
                .environment(dependencies.rulesStore)
                .environment(dependencies.activityStore)
                .environment(dependencies.permissionsManager)
                .environment(dependencies.services)
        }
        .modelContainer(modelContainer)
    }
}
