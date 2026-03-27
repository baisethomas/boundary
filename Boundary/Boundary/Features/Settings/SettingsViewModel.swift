//
//  SettingsViewModel.swift
//  Boundary
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    init() {}

    func refreshPermissions(permissionsManager: PermissionsManager, appState: AppState) async {
        await permissionsManager.refreshStatus()
        appState.syncCalendarPermission(permissionsManager.permissionStatus.calendar)
    }

    func requestCalendarAccess(
        calendarService: CalendarServicing,
        permissionsManager: PermissionsManager,
        appState: AppState
    ) async {
        _ = await calendarService.requestAccess()
        await refreshPermissions(permissionsManager: permissionsManager, appState: appState)
    }

    /// Testing hook: sends the user back through onboarding without deleting rules.
    func resetOnboarding(configuration: AppConfiguration?, modelContext: ModelContext) throws {
        guard let configuration else { return }
        configuration.hasCompletedOnboarding = false
        try modelContext.save()
    }
}
