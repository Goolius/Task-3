import Foundation
import Combine

@MainActor
class RepairViewModelBase: ObservableObject {
    @Published var alertMessage: String?

    func capture(_ error: Error) {
        alertMessage = error.localizedDescription
    }
}

extension Date {
    var repairShortDate: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}
