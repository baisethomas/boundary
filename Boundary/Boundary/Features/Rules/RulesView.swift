//
//  RulesView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct RulesView: View {
    @Environment(RulesStore.self) private var rulesStore
    @Environment(AppState.self) private var appState
    @Environment(ActivityStore.self) private var activityStore
    @Environment(ServiceContainer.self) private var services

    @Bindable var viewModel: RulesViewModel

    @State private var rulePendingDelete: BoundaryRule?
    @State private var showRuleBuilder = false
    @State private var ruleBeingEdited: BoundaryRule?

    private var canAddRule: Bool {
        (try? rulesStore.canAddRule()) ?? false
    }

    private var enabledRules: [BoundaryRule] {
        rulesStore.rules.filter(\.isEnabled).sorted { $0.createdAt > $1.createdAt }
    }

    private var disabledRules: [BoundaryRule] {
        rulesStore.rules.filter { !$0.isEnabled }.sorted { $0.createdAt > $1.createdAt }
    }

    private var persisted: [PersistedRule] {
        (try? rulesStore.persistedRules()) ?? []
    }

    private var showsEntitlementHint: Bool {
        Entitlements.maxRulesForCurrentTier != nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if rulesStore.rules.isEmpty {
                    BoundaryScreen {
                        VStack(spacing: BoundaryTheme.Spacing.xl) {
                            SectionHeader(
                                title: "Rules",
                                subtitle: "Automate quiet time from your calendar and schedule."
                            )
                            EmptyRulesState(
                                canAddRule: canAddRule,
                                onAddRule: { presentBuilder(editing: nil) },
                                onAddSample: { try? rulesStore.addSampleRule() }
                            )
                        }
                    }
                } else {
                    BoundaryScreen {
                        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
                            SectionHeader(
                                title: "Rules",
                                subtitle: "Tap a rule’s menu to edit, or add a new one with the builder."
                            )

                            RuleListView(
                                enabledRules: enabledRules,
                                disabledRules: disabledRules,
                                summaryText: viewModel.evaluateSummary(for: persisted, isPaused: appState.isPaused),
                                showsEntitlementHint: showsEntitlementHint,
                                runStateLine: { viewModel.runStateLine(for: $0, appState: appState) },
                                onToggleEnabled: { rule, isOn in
                                    try? rulesStore.setEnabled(ruleId: rule.id, isEnabled: isOn)
                                    services.activityLogger.logRuleToggled(
                                        name: rule.name,
                                        ruleId: rule.id,
                                        enabled: isOn,
                                        store: activityStore
                                    )
                                },
                                onEdit: { rule in
                                    presentBuilder(editing: rule)
                                },
                                onDelete: { rule in
                                    rulePendingDelete = rule
                                }
                            )

                            AddRuleButton(
                                title: "Add rule",
                                isEnabled: canAddRule
                            ) {
                                presentBuilder(editing: nil)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rules")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button("Add sample rule", systemImage: "square.stack.3d.up") {
                            try? rulesStore.addSampleRule()
                        }
                        .disabled(!canAddRule)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                    Button {
                        presentBuilder(editing: nil)
                    } label: {
                        Label("Add rule", systemImage: "plus")
                    }
                    .disabled(!canAddRule)
                }
            }
            .sheet(isPresented: $showRuleBuilder, onDismiss: { ruleBeingEdited = nil }) {
                NavigationStack {
                    RuleBuilderView(viewModel: RuleBuilderViewModel(editing: ruleBeingEdited))
                        .environment(rulesStore)
                }
            }
            .confirmationDialog(
                "Delete rule?",
                isPresented: Binding(
                    get: { rulePendingDelete != nil },
                    set: { if !$0 { rulePendingDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let rule = rulePendingDelete {
                        try? rulesStore.deleteRule(id: rule.id)
                    }
                    rulePendingDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    rulePendingDelete = nil
                }
            } message: {
                if let rule = rulePendingDelete {
                    Text("“\(rule.name)” will be removed from this device.")
                }
            }
        }
    }

    private func presentBuilder(editing rule: BoundaryRule?) {
        ruleBeingEdited = rule
        showRuleBuilder = true
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    RulesView(viewModel: RulesViewModel(ruleEngine: deps.services.ruleEngine))
        .environment(deps.rulesStore)
        .environment(deps.appState)
        .environment(deps.activityStore)
        .environment(deps.services)
        .modelContainer(PreviewPersistence.inMemoryContainer())
}
