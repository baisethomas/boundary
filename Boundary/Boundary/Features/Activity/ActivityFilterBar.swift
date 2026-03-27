//
//  ActivityFilterBar.swift
//  Boundary
//

import SwiftUI

struct ActivityFilterBar: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var selection: ActivityFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BoundaryTheme.Spacing.xs) {
                ForEach(ActivityFilter.allCases) { filter in
                    filterChip(filter)
                }
            }
            .padding(.vertical, BoundaryTheme.Spacing.xxs)
        }
    }

    private func filterChip(_ filter: ActivityFilter) -> some View {
        let on = selection == filter
        return Button {
            selection = filter
        } label: {
            Text(filter.title)
                .font(BoundaryTheme.Typography.caption.weight(.semibold))
                .padding(.horizontal, BoundaryTheme.Spacing.md)
                .padding(.vertical, BoundaryTheme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(
                            on
                                ? BoundaryTheme.Colors.statusEmphasisBackground(colorScheme)
                                : BoundaryTheme.Colors.statusNeutralBackground(colorScheme)
                        )
                )
                .overlay(
                    Capsule()
                        .strokeBorder(
                            on ? BoundaryTheme.Colors.statusEmphasis(colorScheme).opacity(0.35) : BoundaryTheme.Colors.separator(colorScheme),
                            lineWidth: on ? 1.5 : 0.5
                        )
                )
                .foregroundStyle(on ? BoundaryTheme.Colors.statusEmphasis(colorScheme) : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

#Preview {
    struct Host: View {
        @State private var f = ActivityFilter.all
        var body: some View {
            ActivityFilterBar(selection: $f)
                .padding()
        }
    }
    return Host()
}
