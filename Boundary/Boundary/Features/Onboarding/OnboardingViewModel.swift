//
//  OnboardingViewModel.swift
//  Boundary
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
    private let configuration: AppConfiguration
    private let permissionsManager: any PermissionsManaging

    var permissionStatus: PermissionStatus = .mock

    init(configuration: AppConfiguration, permissionsManager: any PermissionsManaging) {
        self.configuration = configuration
        self.permissionsManager = permissionsManager
    }

    func refreshPermissions() async {
        permissionStatus = await permissionsManager.currentStatus()
    }

    func completeOnboarding(using context: ModelContext) {
        configuration.hasCompletedOnboarding = true
        try? context.save()
    }
}
