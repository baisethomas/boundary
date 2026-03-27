//
//  StatusBadge.swift
//  Boundary
//

import SwiftUI

struct StatusBadge: View {
    enum Style {
        case active
        case idle
        case pending
    }

    let text: String
    var style: Style = .idle

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor.opacity(0.15), in: Capsule())
            .foregroundStyle(backgroundColor)
    }

    private var backgroundColor: Color {
        switch style {
        case .active: .green
        case .idle: .secondary
        case .pending: .orange
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        StatusBadge(text: "Quiet", style: .active)
        StatusBadge(text: "Off", style: .idle)
    }
}
