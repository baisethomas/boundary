//
//  CalendarTriggerEditorCard.swift
//  Boundary
//

import SwiftUI

extension CalendarMatchType {
    fileprivate var builderDisplayName: String {
        switch self {
        case .keywordPartial: "Contains keyword"
        case .keywordExact: "Exact title match"
        }
    }
}

struct CalendarTriggerEditorCard: View {
    @Binding var keywords: [String]
    @Binding var keywordDraft: String
    @Binding var matchType: CalendarMatchType
    @Binding var allowedEventTypes: Set<CalendarEventType>

    var body: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                Text("Keywords")
                    .font(BoundaryTheme.Typography.headline)
                KeywordChipInput(
                    keywords: $keywords,
                    draft: $keywordDraft,
                    suggestions: RuleBuilderKeywordSuggestions.calendar
                )

                Text("Match style")
                    .font(BoundaryTheme.Typography.headline)
                Picker("Match style", selection: $matchType) {
                    ForEach(CalendarMatchType.allCases) { style in
                        Text(style.builderDisplayName).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                Text("Event types")
                    .font(BoundaryTheme.Typography.headline)
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
                    ForEach(CalendarEventType.allCases) { type in
                        Toggle(isOn: binding(for: type)) {
                            Text(eventTypeLabel(type))
                                .font(BoundaryTheme.Typography.body)
                        }
                        .tint(.accentColor)
                    }
                }

                Text("At least one keyword is required. If no event type is selected, Standard is used when saving.")
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func eventTypeLabel(_ type: CalendarEventType) -> String {
        switch type {
        case .standard: "Standard events"
        case .allDay: "All-day"
        case .outOfOffice: "Out of office"
        case .focus: "Focus"
        }
    }

    private func binding(for type: CalendarEventType) -> Binding<Bool> {
        Binding(
            get: { allowedEventTypes.contains(type) },
            set: { on in
                if on {
                    allowedEventTypes.insert(type)
                } else {
                    allowedEventTypes.remove(type)
                }
            }
        )
    }
}

#Preview {
    struct Host: View {
        @State private var keys = ["OOO"]
        @State private var draft = ""
        @State private var match = CalendarMatchType.keywordPartial
        @State private var types: Set<CalendarEventType> = [.standard]
        var body: some View {
            CalendarTriggerEditorCard(
                keywords: $keys,
                keywordDraft: $draft,
                matchType: $match,
                allowedEventTypes: $types
            )
            .padding()
        }
    }
    return Host()
}
