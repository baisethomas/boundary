//
//  RestoreBehaviorSelector.swift
//  Boundary
//

import SwiftUI

struct RestoreBehaviorSelector: View {
    @Binding var selection: RestoreBehavior

    var body: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                Text("When the rule ends")
                    .font(BoundaryTheme.Typography.headline)
                Text("Choose how notifications or Focus should return after this boundary stops.")
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)

                VStack(spacing: BoundaryTheme.Spacing.xs) {
                    ForEach(RestoreBehavior.allCases) { behavior in
                        Button {
                            selection = behavior
                        } label: {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                                    Text(behavior.displayName)
                                        .font(BoundaryTheme.Typography.body.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text(blurb(for: behavior))
                                        .font(BoundaryTheme.Typography.captionSmall)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: selection == behavior ? "largecircle.fill.circle" : "circle")
                                    .foregroundStyle(selection == behavior ? Color.accentColor : Color.secondary.opacity(0.45))
                            }
                            .padding(.vertical, BoundaryTheme.Spacing.xs)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func blurb(for behavior: RestoreBehavior) -> String {
        switch behavior {
        case .revertPrevious: "Return to whatever mode you had before Boundary ran."
        case .default: "Drop to the system default (no special Focus)."
        case .maintain: "Keep the current quiet state until you change it."
        }
    }
}

#Preview {
    struct Host: View {
        @State private var r = RestoreBehavior.revertPrevious
        var body: some View {
            RestoreBehaviorSelector(selection: $r)
                .padding()
        }
    }
    return Host()
}
