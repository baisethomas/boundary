//
//  BoundaryApp.swift
//  Boundary
//

import SwiftData
import SwiftUI

@main
struct BoundaryApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(ServiceContainer.live)
        }
        .modelContainer(SwiftDataPersistenceService.makeModelContainer())
    }
}
