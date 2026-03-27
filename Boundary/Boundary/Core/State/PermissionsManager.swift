//
//  PermissionsManager.swift
//  Boundary
//
//  Calendar, notifications, Focus — Settings and onboarding (PRD State Layer).
//

import Foundation

struct PermissionStatus: Equatable {
    var calendar: CalendarAuthorizationState
    var notificationsGranted: Bool

    static let mock = PermissionStatus(calendar: .mock, notificationsGranted: true)
}

protocol PermissionsManaging: AnyObject {
    func currentStatus() async -> PermissionStatus
}

@MainActor
final class PermissionsManager: PermissionsManaging {
    func currentStatus() async -> PermissionStatus {
        .mock
    }
}
