//
//  AppRouter.swift
//  Boundary
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case rules
    case activity
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .rules: "Rules"
        case .activity: "Activity"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .rules: "slider.horizontal.3"
        case .activity: "clock.arrow.circlepath"
        case .settings: "gearshape.fill"
        }
    }
}

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
}
