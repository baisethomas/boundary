//
//  SettingsView.swift
//  Boundary
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<AppConfiguration> { $0.id == "app.configuration.singleton" })
    private var configurations: [AppConfiguration]

    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Boundaries") {
                    if let config = configurations.first {
                        Toggle("Pause all boundaries", isOn: pauseBinding(for: config))
                    }
                }

                Section("Permissions") {
                    LabeledContent("Calendar") {
                        Text(viewModel.permissionStatus.calendar.rawValue)
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Notifications") {
                        Text(viewModel.permissionStatus.notificationsGranted ? "Granted (mock)" : "Not granted")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    LabeledContent("Build") { Text("MVP scaffold") }
                    Text("Local-first. No account or backend in this build.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .task {
                await viewModel.refresh()
            }
        }
    }

    private func pauseBinding(for config: AppConfiguration) -> Binding<Bool> {
        Binding(
            get: { config.isPaused },
            set: { newValue in
                config.isPaused = newValue
                try? modelContext.save()
            }
        )
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(permissionsManager: PermissionsManager()))
        .modelContainer(for: AppConfiguration.self, inMemory: true)
}
