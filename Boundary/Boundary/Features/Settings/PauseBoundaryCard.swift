//
//  PauseBoundaryCard.swift
//  Boundary
//

import SwiftUI

/// Global pause control with short explanation (syncs with `AppState` via shared `AppConfiguration`).
struct PauseBoundaryCard: View {
    @Binding var isPaused: Bool
    var appStateShowsPaused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
            Toggle(isOn: $isPaused) {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                    Text("Pause all boundaries")
                        .font(BoundaryTheme.Typography.headline)
                    Text("When paused, no rule can activate until you resume. Your rules stay saved.")
                        .font(BoundaryTheme.Typography.bodySecondary)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(.orange)

            HStack(spacing: BoundaryTheme.Spacing.xs) {
                Image(systemName: appStateShowsPaused ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundStyle(.secondary)
                Text(appStateShowsPaused ? "Engine reports paused" : "Engine reports active checks")
                    .font(BoundaryTheme.Typography.captionSmall)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    struct Host: View {
        @State private var p = true
        var body: some View {
            BoundaryCard {
                PauseBoundaryCard(isPaused: $p, appStateShowsPaused: p)
            }
            .padding()
        }
    }
    return Host()
}
