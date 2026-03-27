//
//  PermissionsManager.swift
//  Boundary
//
//  Calendar, notifications, Focus — observable status for Settings and onboarding.
//

import Foundation

struct PermissionStatus: Equatable {
    var calendar: CalendarAuthorizationState
    var notificationsGranted: Bool

    static let mock = PermissionStatus(calendar: .mock, notificationsGranted: true)
}

protocol PermissionsManaging: AnyObject {
    var permissionStatus: PermissionStatus { get }
    func refreshStatus() async
    func currentStatus() async -> PermissionStatus
}

@MainActor
@Observable
final class PermissionsManager: PermissionsManaging {
    private let calendarService: CalendarServicing

    private(set) var permissionStatus: PermissionStatus

    init(calendarService: CalendarServicing) {
        self.calendarService = calendarService
        self.permissionStatus = PermissionStatus(
            calendar: .notDetermined,
            notificationsGranted: true
        )
    }

    func refreshStatus() async {
        permissionStatus = await fetchCalendarAndNotifications()
    }

    func currentStatus() async -> PermissionStatus {
        permissionStatus
    }

    /// Calendar from `CalendarServicing` (EventKit or mock). Notifications: placeholder until UNUserNotificationCenter.
    private func fetchCalendarAndNotifications() async -> PermissionStatus {
        let calendar = await calendarService.authorizationState()
        return PermissionStatus(calendar: calendar, notificationsGranted: true)
    }
}
