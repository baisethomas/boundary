//
//  BoundaryScreen.swift
//  Boundary
//

import SwiftUI

/// Standard screen shell: grouped background, optional scroll, horizontal insets.
struct BoundaryScreen<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    private var scroll: Bool
    @ViewBuilder private var content: () -> Content

    init(scroll: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.scroll = scroll
        self.content = content
    }

    var body: some View {
        Group {
            if scroll {
                ScrollView {
                    content()
                        .padding(.horizontal, BoundaryTheme.Spacing.screenHorizontal)
                        .padding(.vertical, BoundaryTheme.Spacing.md)
                }
            } else {
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, BoundaryTheme.Spacing.screenHorizontal)
                    .padding(.vertical, BoundaryTheme.Spacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BoundaryTheme.Colors.screenBackground(colorScheme).ignoresSafeArea())
    }
}

#Preview("Scroll") {
    NavigationStack {
        BoundaryScreen {
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                SectionHeader(title: "Preview", subtitle: "Calm layout shell")
                BoundaryCard { Text("Content") }
            }
        }
        .navigationTitle("Home")
    }
}

#Preview("Dark") {
    NavigationStack {
        BoundaryScreen {
            Text("Dark mode")
        }
        .navigationTitle("Home")
        .preferredColorScheme(.dark)
    }
}
