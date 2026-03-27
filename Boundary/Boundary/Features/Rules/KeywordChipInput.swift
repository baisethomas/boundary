//
//  KeywordChipInput.swift
//  Boundary
//

import SwiftUI

/// Lightweight keyword entry with removable chips and one-tap suggestions.
struct KeywordChipInput: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var keywords: [String]
    @Binding var draft: String

    let suggestions: [String]
    var placeholder: String = "Add keyword"

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            HStack(spacing: BoundaryTheme.Spacing.sm) {
                TextField(placeholder, text: $draft)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit(addDraftIfNeeded)

                Button("Add", action: addDraftIfNeeded)
                    .font(BoundaryTheme.Typography.caption.weight(.semibold))
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(BoundaryTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: BoundaryTheme.Radius.small, style: .continuous)
                    .strokeBorder(BoundaryTheme.Colors.separator(colorScheme), lineWidth: 1)
            )

            if !keywords.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: BoundaryTheme.Spacing.xs) {
                        ForEach(keywords, id: \.self) { keyword in
                            chip(keyword)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
                Text("Suggestions")
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.tertiary)
                FlowKeywordSuggestionsRow(suggestions: suggestions) { suggestion in
                    appendUnique(suggestion)
                }
            }
        }
    }

    private func chip(_ text: String) -> some View {
        HStack(spacing: BoundaryTheme.Spacing.xxs) {
            Text(text)
                .font(BoundaryTheme.Typography.caption)
            Button {
                keywords.removeAll { $0.caseInsensitiveCompare(text) == .orderedSame }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BoundaryTheme.Spacing.sm)
        .padding(.vertical, BoundaryTheme.Spacing.xxs + 2)
        .background(
            Capsule()
                .fill(BoundaryTheme.Colors.statusNeutralBackground(colorScheme))
        )
    }

    private func addDraftIfNeeded() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        appendUnique(trimmed)
        draft = ""
    }

    private func appendUnique(_ value: String) {
        let lower = value.lowercased()
        guard !keywords.contains(where: { $0.lowercased() == lower }) else { return }
        keywords.append(value)
    }
}

// MARK: - Wrapping suggestion buttons

private struct FlowKeywordSuggestionsRow: View {
    let suggestions: [String]
    let onTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
            let rows = chunked(suggestions, maxPerRow: 3)
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: BoundaryTheme.Spacing.xs) {
                    ForEach(row, id: \.self) { suggestion in
                        Button {
                            onTap(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(BoundaryTheme.Typography.captionSmall.weight(.medium))
                                .padding(.horizontal, BoundaryTheme.Spacing.sm)
                                .padding(.vertical, BoundaryTheme.Spacing.xxs + 2)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func chunked(_ items: [String], maxPerRow: Int) -> [[String]] {
        stride(from: 0, to: items.count, by: maxPerRow).map {
            Array(items[$0 ..< min($0 + maxPerRow, items.count)])
        }
    }
}

#Preview {
    struct Host: View {
        @State private var keys = ["OOO", "Focus"]
        @State private var draft = ""
        var body: some View {
            KeywordChipInput(
                keywords: $keys,
                draft: $draft,
                suggestions: RuleBuilderKeywordSuggestions.calendar
            )
            .padding()
        }
    }
    return Host()
}
