//
//  RulesStore.swift
//  Boundary
//
//  PRD Section 6 — rule persistence facade + free-tier limit (Section 18).
//

import SwiftData
import SwiftUI

enum Entitlements {
    /// Stub: flip when Pro is implemented.
    static var isProSubscriber: Bool { false }

    /// `nil` means unlimited.
    static var maxRulesForCurrentTier: Int? {
        isProSubscriber ? nil : 1
    }
}

@MainActor
@Observable
final class RulesStore {
    private var modelContext: ModelContext?

    func bind(_ context: ModelContext) {
        modelContext = context
    }

    private func requireContext() -> ModelContext {
        guard let modelContext else {
            fatalError("RulesStore used before bind(modelContext:)")
        }
        return modelContext
    }

    func fetchAll() throws -> [PersistedRule] {
        var descriptor = FetchDescriptor<PersistedRule>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try requireContext().fetch(descriptor)
    }

    func enabledRuleCount() throws -> Int {
        let all = try fetchAll()
        return all.filter(\.isEnabled).count
    }

    func canAddRule() throws -> Bool {
        guard let max = Entitlements.maxRulesForCurrentTier else { return true }
        return try fetchAll().count < max
    }

    func addSampleRule() throws {
        let context = requireContext()
        guard try canAddRule() else { return }
        let index = try context.fetchCount(FetchDescriptor<PersistedRule>())
        let title = "Sample rule \(index + 1)"
        context.insert(PersistedRule(title: title, preset: QuietPreset.allCases[index % QuietPreset.allCases.count]))
        try context.save()
    }

    func setEnabled(_ rule: PersistedRule, isEnabled: Bool) throws {
        rule.isEnabled = isEnabled
        try requireContext().save()
    }
}
