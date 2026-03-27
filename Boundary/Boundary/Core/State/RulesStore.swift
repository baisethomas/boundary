//
//  RulesStore.swift
//  Boundary
//
//  Rule list for UI + persistence; starts with mock `BoundaryRule`s until SwiftData hydrates.
//

import SwiftData
import SwiftUI

enum RulesStoreError: LocalizedError {
    case ruleLimitReached

    var errorDescription: String? {
        switch self {
        case .ruleLimitReached:
            return "You’ve reached the rule limit for your plan."
        }
    }
}

enum Entitlements {
    static var isProSubscriber: Bool { false }

    static var maxRulesForCurrentTier: Int? {
        isProSubscriber ? nil : 1
    }
}

@MainActor
@Observable
final class RulesStore {
    private var modelContext: ModelContext?

    /// Value-type rows for lists and previews; replaced from disk when persistence is attached.
    private(set) var rules: [BoundaryRule] = MockData.sampleRules

    var isPersistenceBound: Bool { modelContext != nil }

    func bind(_ context: ModelContext) {
        modelContext = context
        try? refreshFromPersistence()
    }

    private func requireContext() -> ModelContext {
        guard let modelContext else {
            fatalError("RulesStore used before bind(modelContext:)")
        }
        return modelContext
    }

    /// Persisted models for the rule engine and summary helpers.
    func persistedRules() throws -> [PersistedRule] {
        guard let modelContext else {
            return []
        }
        var descriptor = FetchDescriptor<PersistedRule>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }

    func refreshFromPersistence() throws {
        guard modelContext != nil else { return }
        let fetched = try persistedRules()
        rules = fetched.map(\.boundaryRule)
    }

    func enabledPersistedCount() throws -> Int {
        try persistedRules().filter(\.isEnabled).count
    }

    func canAddRule() throws -> Bool {
        guard modelContext != nil else { return true }
        guard let max = Entitlements.maxRulesForCurrentTier else { return true }
        return try persistedRules().count < max
    }

    func addSampleRule() throws {
        let context = requireContext()
        guard try canAddRule() else { return }
        let index = try context.fetchCount(FetchDescriptor<PersistedRule>())
        let title = "Sample rule \(index + 1)"
        context.insert(PersistedRule(title: title, preset: QuietPreset.allCases[index % QuietPreset.allCases.count]))
        try context.save()
        try refreshFromPersistence()
    }

    func setEnabled(_ rule: PersistedRule, isEnabled: Bool) throws {
        rule.isEnabled = isEnabled
        try requireContext().save()
        try refreshFromPersistence()
    }

    func setEnabled(ruleId: UUID, isEnabled: Bool) throws {
        guard let model = try persistedRules().first(where: { $0.id == ruleId }) else { return }
        try setEnabled(model, isEnabled: isEnabled)
    }

    func deleteRule(id: UUID) throws {
        let context = requireContext()
        guard let model = try persistedRules().first(where: { $0.id == id }) else { return }
        context.delete(model)
        try context.save()
        try refreshFromPersistence()
    }

    /// Inserts a new rule from the builder. Respects free-tier limits.
    func createRule(
        title: String,
        isEnabled: Bool = true,
        trigger: RuleTrigger,
        quietProfile: QuietModeProfile,
        restoreBehavior: RestoreBehavior
    ) throws {
        let context = requireContext()
        guard try canAddRule() else { throw RulesStoreError.ruleLimitReached }
        let model = PersistedRule(
            title: title,
            isEnabled: isEnabled,
            preset: .afterHours,
            trigger: trigger,
            quietProfile: quietProfile,
            restoreBehavior: restoreBehavior
        )
        context.insert(model)
        try context.save()
        try refreshFromPersistence()
    }

    /// Updates an existing persisted rule (builder edit mode).
    func updateRule(
        id: UUID,
        title: String,
        trigger: RuleTrigger,
        quietProfile: QuietModeProfile,
        restoreBehavior: RestoreBehavior
    ) throws {
        guard let model = try persistedRules().first(where: { $0.id == id }) else { return }
        model.title = title
        model.trigger = trigger
        model.quietProfile = quietProfile
        model.restoreBehavior = restoreBehavior
        try requireContext().save()
        try refreshFromPersistence()
    }
}
