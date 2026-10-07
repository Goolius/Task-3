import Foundation
import Combine

@MainActor
final class PropertySettingsViewModel: RepairViewModelBase {
    @Published var property: RentalProperty = .blank
    @Published private(set) var saved = false

    private let reviewUseCase: ReviewRentalPropertyUseCase
    private let saveUseCase: SaveRentalPropertyUseCase

    init(reviewUseCase: ReviewRentalPropertyUseCase, saveUseCase: SaveRentalPropertyUseCase) {
        self.reviewUseCase = reviewUseCase
        self.saveUseCase = saveUseCase
    }

    func load() {
        do {
            property = try reviewUseCase.execute() ?? .blank
        } catch {
            capture(error)
        }
    }

    func save() {
        do {
            try saveUseCase.execute(property)
            saved = true
        } catch {
            saved = false
            capture(error)
        }
    }
}
