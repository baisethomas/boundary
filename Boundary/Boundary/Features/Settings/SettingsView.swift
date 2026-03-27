//
//  SettingsView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PermissionsManager.self) private var permissionsManager
    @Environment(ServiceContainer.self) private var services
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" })
    private var configurations: [AppConfiguration]

    @Bindable var viewModel: SettingsViewModel

    @State private var showResetOnboardingConfirm = false

    private var configuration: AppConfiguration? { configurations.first }

    var body: some View {
        NavigationStack {
            BoundaryScreen {
                VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.xl) {
                    SectionHeader(
                        title: "Settings",
                        subtitle: "Permissions, boundaries, and defaults — minimal and in your control."
                    )

                    SettingsSectionCard(
                        title: "Permissions",
                        subtitle: "What Boundary can use on this device."
                    ) {
                        PermissionStatusRow(
                            calendarState: permissionsManager.permissionStatus.calendar,
                            notificationsGranted: permissionsManager.permissionStatus.notificationsGranted,
                            onRefresh: {
                                Task {
                                    await viewModel.refreshPermissions(
                                        permissionsManager: permissionsManager,
                                        appState: appState
                                    )
                                }
                            },
                            onRequestCalendarAccess: {
                                Task {
                                    await viewModel.requestCalendarAccess(
                                        calendarService: services.calendarService,
                                        permissionsManager: permissionsManager,
                                        appState: appState
                                    )
                                }
                            }
                        )
                        .padding(.vertical, BoundaryTheme.Spacing.xs)
                    }

                    SettingsSectionCard(
                        title: "Boundaries",
                        subtitle: "Global pause and default behavior for new rules."
                    ) {
                        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.md) {
                            if let config = configuration {
                                PauseBoundaryCard(
                                    isPaused: pauseBinding(for: config),
                                    appStateShowsPaused: appState.isPaused
                                )
                                Divider()
                                    .padding(.vertical, BoundaryTheme.Spacing.xxs)
                                RestorePreferencePicker(
                                    selection: defaultRestoreBinding(for: config)
                                )
                            } else {
                                Text("Loading configuration…")
                                    .font(BoundaryTheme.Typography.bodySecondary)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, BoundaryTheme.Spacing.sm)
                            }
                        }
                        .padding(.vertical, BoundaryTheme.Spacing.xs)
                    }

                    SettingsSectionCard(
                        title: "Support",
                        subtitle: "Placeholder links — swap for real URLs before release."
                    ) {
                        VStack(spacing: 0) {
                            HelpLinkRow(
                                title: "Help center",
                                subtitle: "Guides and FAQs (coming soon)",
                                url: URL(string: "https://example.com/help")!
                            )
                            Divider()
                            HelpLinkRow(
                                title: "Contact support",
                                subtitle: "Email or chat (placeholder)",
                                url: URL(string: "https://example.com/support")!
                            )
                            Divider()
                            HelpLinkRow(
                                title: "Privacy policy",
                                subtitle: "Placeholder",
                                url: URL(string: "https://example.com/privacy")!,
                                systemImage: "lock.shield"
                            )
                            Divider()
                            HelpLinkRow(
                                title: "Terms of use",
                                subtitle: "Placeholder",
                                url: URL(string: "https://example.com/terms")!,
                                systemImage: "doc.text"
                            )
                        }
                        .padding(.vertical, BoundaryTheme.Spacing.xs)
                    }

                    SettingsSectionCard(
                        title: "Developer",
                        subtitle: "For testing flows in builds and simulators."
                    ) {
                        VStack(alignment: .leading, spacing: BoundaryTheme.Spacing.sm) {
                            Text("Reset onboarding")
                                .font(BoundaryTheme.Typography.headline)
                            Text("Shows the onboarding flow again. Rules and activity data are not deleted.")
                                .font(BoundaryTheme.Typography.caption)
                                .foregroundStyle(.secondary)

                            SecondaryButton(title: "Reset onboarding…", systemImage: "arrow.counterclockwise") {
                                showResetOnboardingConfirm = true
                            }
                            .padding(.top, BoundaryTheme.Spacing.xs)
                        }
                        .padding(.vertical, BoundaryTheme.Spacing.xs)
                    }

                    SettingsSectionCard(title: "About", subtitle: nil) {
                        AboutBoundaryCard()
                            .padding(.vertical, BoundaryTheme.Spacing.xs)
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                await viewModel.refreshPermissions(
                    permissionsManager: permissionsManager,
                    appState: appState
                )
            }
            .confirmationDialog(
                "Reset onboarding?",
                isPresented: $showResetOnboardingConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset onboarding", role: .destructive) {
                    try? viewModel.resetOnboarding(
                        configuration: configuration,
                        modelContext: modelContext
                    )
                    appState.syncConfiguration(configuration)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You’ll return to the onboarding flow. Rules and history stay on this device.")
            }
        }
    }

    private func pauseBinding(for config: AppConfiguration) -> Binding<Bool> {
        Binding(
            get: { config.isPaused },
            set: { newValue in
                config.isPaused = newValue
                try? modelContext.save()
                appState.syncConfiguration(config)
            }
        )
    }

    private func defaultRestoreBinding(for config: AppConfiguration) -> Binding<RestoreBehavior> {
        Binding(
            get: { config.defaultRestoreBehavior },
            set: { newValue in
                config.defaultRestoreBehavior = newValue
                try? modelContext.save()
            }
        )
    }
}

#Preview {
    let container = PreviewPersistence.inMemoryContainer()
    PreviewSampleData.configure(container.mainContext)
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    return SettingsView(viewModel: SettingsViewModel())
        .modelContainer(container)
        .environment(deps.appState)
        .environment(deps.permissionsManager)
        .environment(deps.services)
}
