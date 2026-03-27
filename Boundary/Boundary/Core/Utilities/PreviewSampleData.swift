//
//  PreviewSampleData.swift
//  Boundary
//

import SwiftData
import SwiftUI

enum PreviewSampleData {
    static func configure(_ container: ModelContext) {
        SwiftDataPersistenceService.shared.ensureSingletonConfiguration(in: container)
        if let config = try? container.fetch(
            FetchDescriptor<AppConfiguration>(
                predicate: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" }
            )
        ).first {
            config.hasCompletedOnboarding = true
        }
        if (try? container.fetchCount(FetchDescriptor<PersistedRule>())) == 0 {
            container.insert(PersistedRule(title: "After hours", preset: .afterHours))
            container.insert(PersistedRule(title: "Deep work", preset: .deepWork))
        }
        if (try? container.fetchCount(FetchDescriptor<ActivityEvent>())) == 0 {
            container.insert(
                ActivityEvent(title: "Boundary armed", detail: "Mock event", kind: .activated)
            )
        }
        try? container.save()
    }
}
