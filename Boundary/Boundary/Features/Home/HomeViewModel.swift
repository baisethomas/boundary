//
//  HomeViewModel.swift
//  Boundary
//

import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    private let calendarService: any CalendarServicing

    var calendarState: CalendarAuthorizationState = .mock

    init(calendarService: any CalendarServicing) {
        self.calendarService = calendarService
    }

    func loadCalendarState() async {
        calendarState = await calendarService.authorizationState()
    }
}
