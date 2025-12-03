import Foundation
import SwiftUI

/// State management for menu bar interactions
class MenuBarState: ObservableObject {
    @Published var isShowingClearConfirmation: Bool = false

    func showClearConfirmation() {
        isShowingClearConfirmation = true
    }

    func dismissClearConfirmation() {
        isShowingClearConfirmation = false
    }
}
