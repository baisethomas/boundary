//
//  SettingsViewModel.swift
//  Boundary
//

import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    private let permissionsManager: any PermissionsManaging

    var permissionStatus: PermissionStatus = .mock

    init(permissionsManager: any PermissionsManaging) {
        self.permissionsManager = permissionsManager
    }

    func refresh() async {
        permissionStatus = await permissionsManager.currentStatus()
    }
}
