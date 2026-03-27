//
//  OnboardingView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeader(
                    title: "Welcome to Boundary",
                    subtitle: "Automatic quiet time from your calendar and rules."
                )

                BoundaryCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What you get")
                            .font(.headline)
                        Text("After hours, out-of-office, and deep work presets with a local-first activity log (mock data in this build).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Permissions (preview)")
                        .font(.subheadline.weight(.semibold))
                    Text("Calendar: \(viewModel.permissionStatus.calendar.rawValue)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                PrimaryButton(title: "Get started", systemImage: "checkmark.circle.fill") {
                    viewModel.completeOnboarding(using: modelContext)
                }
            }
            .boundaryScreenPadding()
            .padding(.vertical, 32)
        }
        .task {
            await viewModel.refreshPermissions()
        }
    }
}

#Preview {
    let config = AppConfiguration(hasCompletedOnboarding: false)
    return OnboardingView(viewModel: OnboardingViewModel(configuration: config, permissionsManager: PermissionsManager()))
        .modelContainer(for: AppConfiguration.self, inMemory: true)
}
