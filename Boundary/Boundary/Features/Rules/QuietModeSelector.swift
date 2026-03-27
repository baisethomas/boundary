//
//  QuietModeSelector.swift
//  Boundary
//

import SwiftUI

struct QuietModeSelector: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var modeType: QuietModeType
    @Binding var customDisplayName: String

    var body: some View {
        BoundaryCard {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                Text("Quiet mode")
                    .font(BoundaryTheme.Typography.headline)

                VStack(spacing: BoundaryTheme.Spacing.sm) {
                    ForEach(QuietModeType.allCases) { type in
                        Button {
                            modeType = type
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                                    Text(type.displayName)
                                        .font(BoundaryTheme.Typography.body.weight(.medium))
                                    Text(quietBlurb(for: type))
                                        .font(BoundaryTheme.Typography.captionSmall)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if modeType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(BoundaryTheme.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: BoundaryTheme.Radius.small, style: .continuous)
                                    .fill(
                                        modeType == type
                                            ? BoundaryTheme.Colors.statusEmphasisBackground(colorScheme)
                                            : BoundaryTheme.Colors.statusNeutralBackground(colorScheme)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if modeType == .custom {
                    VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xs) {
                        Text("Custom label")
                            .font(BoundaryTheme.Typography.captionSmall)
                            .foregroundStyle(.tertiary)
                        TextField("Name shown in the app", text: $customDisplayName)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.top, BoundaryTheme.Spacing.xs)
                }
            }
        }
    }

    private func quietBlurb(for type: QuietModeType) -> String {
        switch type {
        case .doNotDisturb: "Strongest quiet — closest to system Do Not Disturb."
        case .personal: "Softer personal boundary."
        case .work: "Work-focused quiet profile."
        case .sleep: "Minimal overnight-style interruptions."
        case .custom: "Name your own profile for now."
        }
    }
}

#Preview {
    struct Host: View {
        @State private var t = QuietModeType.doNotDisturb
        @State private var c = ""
        var body: some View {
            QuietModeSelector(modeType: $t, customDisplayName: $c)
                .padding()
        }
    }
    return Host()
}
