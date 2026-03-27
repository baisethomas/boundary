//
//  OnboardingCalendarStepView.swift
//  Boundary
//
//  EventKit-backed `CalendarServicing` + `PermissionsManager`; previews inject `MockCalendarService`.
//

import SwiftUI

struct OnboardingCalendarStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(PermissionsManager.self) private var permissionsManager
    @Environment(ServiceContainer.self) private var services

    @State private var isRequesting = false

    var body: some View {
        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.lg) {
            BoundaryCard {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                    Label("Calendar access", systemImage: "calendar")
                        .font(BoundaryTheme.Typography.headline)
                    Text(
                        "Boundary reads event titles and times to match out-of-office and focus blocks. "
                            + "We never upload your calendar—integrations stay on device as we ship EventKit support."
                    )
                    .font(BoundaryTheme.Typography.bodySecondary)
                    .foregroundStyle(.secondary)
                }
            }

            if isRequesting {
                ProgressView("Updating…")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BoundaryTheme.Spacing.sm)
            } else {
                PrimaryButton(title: "Allow calendar access", systemImage: "checkmark.shield.fill") {
                    Task {
                        isRequesting = true
                        await viewModel.requestCalendarAccess(
                            calendarService: services.calendarService,
                            permissionsManager: permissionsManager
                        )
                        isRequesting = false
                        viewModel.goForward()
                    }
                }

                SecondaryButton(title: "Not now", systemImage: "arrow.right.circle") {
                    viewModel.markCalendarSkipped()
                    viewModel.goForward()
                }
            }

            Text("Current status: \(permissionsManager.permissionStatus.calendar.rawValue)")
                .font(BoundaryTheme.Typography.captionSmall)
                .foregroundStyle(.tertiary)
        }
        .task {
            await permissionsManager.refreshStatus()
        }
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    let config = AppConfiguration(hasCompletedOnboarding: false)
    return NavigationStack {
        BoundaryScreen {
            OnboardingCalendarStepView(viewModel: OnboardingViewModel(configuration: config))
                .environment(deps.permissionsManager)
                .environment(deps.services)
        }
    }
}
