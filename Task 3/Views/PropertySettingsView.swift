import SwiftUI

struct PropertySettingsView: View {
    @StateObject private var viewModel: PropertySettingsViewModel

    init(dependencies: AppDependencies) {
        _viewModel = StateObject(
            wrappedValue: PropertySettingsViewModel(
                reviewUseCase: dependencies.reviewProperty,
                saveUseCase: dependencies.saveProperty
            )
        )
    }

    var body: some View {
        Form {
            Section("Rental property") {
                TextField("Nickname", text: $viewModel.property.nickname)
                TextField("Address", text: $viewModel.property.addressLine, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Landlord or agent") {
                TextField("Name", text: $viewModel.property.landlordOrAgentName)
                TextField("Preferred contact", text: $viewModel.property.preferredContact)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            Section {
                Button {
                    viewModel.save()
                } label: {
                    Label("Save property details", systemImage: "checkmark.circle")
                }

                if viewModel.saved {
                    Label("Property details saved", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            } footer: {
                Text("Repair timelines are stronger when every issue is linked to the same property and contact.")
            }
        }
        .navigationTitle("Property")
        .task {
            viewModel.load()
        }
        .repairAlert(message: $viewModel.alertMessage)
    }
}

