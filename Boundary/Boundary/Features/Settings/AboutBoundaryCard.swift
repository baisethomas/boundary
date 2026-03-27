//
//  AboutBoundaryCard.swift
//  Boundary
//

import SwiftUI

struct AboutBoundaryCard: View {
    private var version: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "—"
    }

    private var build: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "—"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            LabeledContent("Version") {
                Text(version)
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Build") {
                Text(build)
                    .foregroundStyle(.secondary)
            }
            Text("Boundary runs on your device. This MVP has no account or cloud sync.")
                .font(BoundaryTheme.Typography.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, BoundaryTheme.Spacing.xxs)
        }
    }
}

#Preview {
    BoundaryCard {
        AboutBoundaryCard()
    }
    .padding()
}
