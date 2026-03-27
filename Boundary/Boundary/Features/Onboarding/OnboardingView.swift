//
//  OnboardingView.swift
//  Boundary
//
//  Entry point — hosts `OnboardingFlowView` and inherits app `Environment` from `RootView`.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingFlowView(viewModel: viewModel)
    }
}

#Preview {
    let deps = BoundaryDependencies(calendarService: MockCalendarService())
    let config = AppConfiguration(hasCompletedOnboarding: false)
    return OnboardingView(viewModel: OnboardingViewModel(configuration: config))
        .environment(deps.permissionsManager)
        .environment(deps.services)
        .environment(deps.rulesStore)
        .modelContainer(PreviewPersistence.inMemoryContainer())
}
