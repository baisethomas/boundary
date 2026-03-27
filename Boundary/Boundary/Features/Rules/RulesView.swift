//
//  RulesView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct RulesView: View {
    @Environment(RulesStore.self) private var rulesStore
    @Query(filter: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" })
    private var configurations: [AppConfiguration]

    @Query(sort: \PersistedRule.createdAt, order: .reverse) private var rules: [PersistedRule]
    @Bindable var viewModel: RulesViewModel

    private var isPaused: Bool {
        configurations.first?.isPaused ?? false
    }

    private var canAddRule: Bool {
        (try? rulesStore.canAddRule()) ?? false
    }

    var body: some View {
        NavigationStack {
            Group {
                if rules.isEmpty {
                    ContentUnavailableView(
                        "No rules yet",
                        systemImage: "slider.horizontal.3",
                        description: Text("Add a sample rule to see the list. Rule builder UI comes next.")
                    )
                } else {
                    List {
                        Section {
                            Text(viewModel.evaluateSummary(for: rules, isPaused: isPaused))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if Entitlements.maxRulesForCurrentTier != nil {
                                Text("Free: 1 rule. Upgrade for unlimited.")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        ForEach(rules) { rule in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(rule.title)
                                        .font(.headline)
                                    Spacer()
                                    StatusBadge(text: rule.isEnabled ? "On" : "Off", style: rule.isEnabled ? .active : .idle)
                                }
                                Text(triggerLabel(for: rule))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(rule.preset.displayName) · \(rule.quietMode.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Rules")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        try? rulesStore.addSampleRule()
                    } label: {
                        Label("Add sample", systemImage: "plus")
                    }
                    .disabled(!canAddRule)
                }
            }
        }
    }

    private func triggerLabel(for rule: PersistedRule) -> String {
        switch rule.trigger {
        case .schedule: "Schedule trigger"
        case .calendar: "Calendar trigger"
        case .hybrid: "Hybrid trigger"
        }
    }
}

#Preview {
    RulesView(viewModel: RulesViewModel(ruleEngine: RuleEngine()))
        .environment(RulesStore())
        .modelContainer(for: [PersistedRule.self, AppConfiguration.self], inMemory: true)
}
