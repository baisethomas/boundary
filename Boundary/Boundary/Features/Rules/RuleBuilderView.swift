//
//  RuleBuilderView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct RuleBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RulesStore.self) private var rulesStore

    @Bindable var viewModel: RuleBuilderViewModel

    var body: some View {
        BoundaryScreen {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
                stepIndicator

                Group {
                    switch viewModel.step {
                    case .basics:
                        basicsStep
                    case .trigger:
                        triggerStep
                    case .quiet:
                        quietStep
                    case .review:
                        reviewStep
                    }
                }

                if let err = viewModel.saveError {
                    Text(err)
                        .font(BoundaryTheme.Typography.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit rule" : "New rule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarLeading) {
                if viewModel.step != .basics {
                    Button {
                        viewModel.goBack()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.step == .review {
                    Button("Save") { saveAndDismiss() }
                        .fontWeight(.semibold)
                        .disabled(!viewModel.canSave)
                } else {
                    Button("Next") { viewModel.goNext() }
                        .fontWeight(.semibold)
                        .disabled(!viewModel.canProceedFromCurrentStep)
                }
            }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: BoundaryTheme.Spacing.xs) {
            ForEach(RuleBuilderStep.allCases) { s in
                Capsule()
                    .fill(s.rawValue <= viewModel.step.rawValue ? Color.primary.opacity(0.35) : Color.primary.opacity(0.1))
                    .frame(height: 4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(viewModel.step.rawValue + 1) of \(RuleBuilderStep.allCases.count), \(viewModel.step.title)")
    }

    private var basicsStep: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
            Text(viewModel.step.title)
                .font(BoundaryTheme.Typography.sectionTitle)
            Text("Name your rule and choose how Boundary should decide when to turn on.")
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)

            BoundaryCard {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                    Text("Rule name")
                        .font(BoundaryTheme.Typography.headline)
                    TextField("e.g. After hours", text: $viewModel.ruleName)
                        .textFieldStyle(.roundedBorder)
                }
            }

            TriggerTypePicker(selection: $viewModel.triggerKind)

            if let msg = viewModel.basicsValidationMessage {
                Text(msg)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var triggerStep: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
            Text(viewModel.step.title)
                .font(BoundaryTheme.Typography.sectionTitle)
            Text("Configure when this rule is allowed to run.")
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)

            switch viewModel.triggerKind {
            case .schedule:
                ScheduleEditorCard(
                    selectedWeekdays: $viewModel.scheduleWeekdays,
                    startTime: $viewModel.scheduleStart,
                    endTime: $viewModel.scheduleEnd
                )
            case .calendar:
                CalendarTriggerEditorCard(
                    keywords: $viewModel.calendarKeywords,
                    keywordDraft: $viewModel.calendarKeywordDraft,
                    matchType: $viewModel.calendarMatchType,
                    allowedEventTypes: $viewModel.calendarEventTypes
                )
            case .hybrid:
                ScheduleEditorCard(
                    selectedWeekdays: $viewModel.scheduleWeekdays,
                    startTime: $viewModel.scheduleStart,
                    endTime: $viewModel.scheduleEnd
                )
                CalendarTriggerEditorCard(
                    keywords: $viewModel.calendarKeywords,
                    keywordDraft: $viewModel.calendarKeywordDraft,
                    matchType: $viewModel.calendarMatchType,
                    allowedEventTypes: $viewModel.calendarEventTypes
                )
            }

            if let msg = viewModel.triggerValidationMessage {
                Text(msg)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var quietStep: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
            Text(viewModel.step.title)
                .font(BoundaryTheme.Typography.sectionTitle)
            Text("Pick how aggressively Boundary quiets interruptions, and what happens when the rule ends.")
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)

            QuietModeSelector(modeType: $viewModel.quietModeType, customDisplayName: $viewModel.customQuietName)
            RestoreBehaviorSelector(selection: $viewModel.restoreBehavior)

            if let msg = viewModel.quietValidationMessage {
                Text(msg)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
            Text(viewModel.step.title)
                .font(BoundaryTheme.Typography.sectionTitle)
            Text("Confirm everything looks right, then save to \(viewModel.isEditing ? "update" : "add") this rule.")
                .font(BoundaryTheme.Typography.bodySecondary)
                .foregroundStyle(.secondary)

            ReviewRuleCard(viewModel: viewModel)
        }
    }

    private func saveAndDismiss() {
        do {
            try viewModel.save(using: rulesStore)
            dismiss()
        } catch {
            viewModel.saveError = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
    }
}

#Preview("Create") {
    NavigationStack {
        RuleBuilderPreviewHost()
    }
    .modelContainer(for: PersistedRule.self, inMemory: true)
}

private struct RuleBuilderPreviewHost: View {
    @Environment(\.modelContext) private var modelContext
    private let deps = BoundaryDependencies(calendarService: MockCalendarService())

    var body: some View {
        RuleBuilderView(viewModel: RuleBuilderViewModel())
            .environment(deps.rulesStore)
            .task { deps.rulesStore.bind(modelContext) }
    }
}
