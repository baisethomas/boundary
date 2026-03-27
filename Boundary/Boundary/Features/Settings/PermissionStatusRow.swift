//
//  PermissionStatusRow.swift
//  Boundary
//

import SwiftUI

extension CalendarAuthorizationState {
    fileprivate var settingsHeadline: String {
        switch self {
        case .authorized: "Allowed"
        case .denied: "Denied"
        case .restricted: "Restricted"
        case .notDetermined: "Not determined"
        case .mock: "Simulator"
        }
    }

    fileprivate var settingsDetail: String {
        switch self {
        case .authorized:
            return "Calendar events can drive rules and matching."
        case .denied, .restricted:
            return "Open Settings › Boundary to enable Calendar when you’re ready."
        case .notDetermined:
            return "Grant access so OOO and focus-style rules can use your events."
        case .mock:
            return "Preview / test double — not used by the real EventKit service."
        }
    }
}

struct PermissionStatusRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let calendarState: CalendarAuthorizationState
    let notificationsGranted: Bool
    var onRefresh: () -> Void
    var onRequestCalendarAccess: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
            row(
                icon: "calendar",
                title: "Calendar",
                headline: calendarState.settingsHeadline,
                detail: calendarState.settingsDetail
            )

            if calendarState == .notDetermined || calendarState == .denied {
                SecondaryButton(title: "Request calendar access", systemImage: "calendar.badge.plus") {
                    onRequestCalendarAccess()
                }
            }

            Divider()
                .background(BoundaryTheme.Colors.separator(colorScheme))
                .padding(.vertical, BoundaryTheme.Spacing.xxs)

            row(
                icon: "bell.badge",
                title: "Notifications",
                headline: notificationsGranted ? "Ready (mock)" : "Not granted",
                detail: "Used later for Boundary alerts and nudges. System prompt TBD."
            )

            Button {
                onRefresh()
            } label: {
                Label("Refresh permission status", systemImage: "arrow.clockwise")
                    .font(BoundaryTheme.Typography.caption.weight(.semibold))
            }
            .padding(.top, BoundaryTheme.Spacing.xs)
        }
    }

    private func row(icon: String, title: String, headline: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: BoundaryTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xxs) {
                Text(title)
                    .font(BoundaryTheme.Typography.headline)
                Text(headline)
                    .font(BoundaryTheme.Typography.bodySecondary.weight(.semibold))
                    .foregroundStyle(BoundaryTheme.Colors.statusEmphasis(colorScheme))
                Text(detail)
                    .font(BoundaryTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    PermissionStatusRow(
        calendarState: .authorized,
        notificationsGranted: true,
        onRefresh: {},
        onRequestCalendarAccess: {}
    )
    .padding()
}
