//
//  RestorePreferencePicker.swift
//  Boundary
//

import SwiftUI

/// Default restore behavior for **new** rules (builder can read this when creating rules).
struct RestorePreferencePicker: View {
    @Binding var selection: RestoreBehavior

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
            Text("Applies to new rules you create. Existing rules keep their own setting.")
                .font(BoundaryTheme.Typography.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text("Default")
                    .font(BoundaryTheme.Typography.body)
                Spacer()
                Picker("Default restore behavior", selection: $selection) {
                    ForEach(RestoreBehavior.allCases) { behavior in
                        Text(behavior.displayName).tag(behavior)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }
        }
    }
}

#Preview {
    struct Host: View {
        @State private var r = RestoreBehavior.revertPrevious
        var body: some View {
            BoundaryCard {
                RestorePreferencePicker(selection: $r)
            }
            .padding()
        }
    }
    return Host()
}
