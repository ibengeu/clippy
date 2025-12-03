import Foundation
import SwiftUI

// MARK: - Onboarding Step Enum

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case permissions = 1
    case shortcut = 2
    case privacy = 3
    case tips = 4

    var title: String {
        switch self {
        case .welcome:
            return "Welcome to SwiftClip"
        case .permissions:
            return "Accessibility Permission"
        case .shortcut:
            return "Keyboard Shortcut"
        case .privacy:
            return "Privacy Settings"
        case .tips:
            return "Quick Tips"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome:
            return "Your clipboard, smarter and faster."
        case .permissions:
            return "Required to capture keyboard shortcuts and monitor clipboard"
        case .shortcut:
            return "Customize how you access your clipboard history"
        case .privacy:
            return "Control which apps are tracked"
        case .tips:
            return "Get the most out of SwiftClip"
        }
    }

    var icon: String {
        switch self {
        case .welcome:
            return "doc.on.clipboard.fill"
        case .permissions:
            return "lock.shield"
        case .shortcut:
            return "command"
        case .privacy:
            return "hand.raised.shield"
        case .tips:
            return "lightbulb.fill"
        }
    }
}

// MARK: - Onboarding State

class OnboardingState: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome

    var currentStepIndex: Int {
        return currentStep.rawValue
    }

    var canGoNext: Bool {
        return currentStepIndex < OnboardingStep.allCases.count - 1
    }

    var canGoPrevious: Bool {
        return currentStepIndex > 0
    }

    var isFirstStep: Bool {
        return currentStep == .welcome
    }

    var isLastStep: Bool {
        return currentStep == .tips
    }

    var progress: Double {
        let totalSteps = OnboardingStep.allCases.count
        return Double(currentStepIndex) / Double(totalSteps - 1)
    }

    func nextStep() {
        guard canGoNext else { return }
        if let nextStep = OnboardingStep(rawValue: currentStepIndex + 1) {
            currentStep = nextStep
        }
    }

    func previousStep() {
        guard canGoPrevious else { return }
        if let prevStep = OnboardingStep(rawValue: currentStepIndex - 1) {
            currentStep = prevStep
        }
    }

    func goToStep(_ step: OnboardingStep) {
        currentStep = step
    }

    // MARK: - Persistence

    static func markAsCompleted(userDefaults: UserDefaults = .standard) {
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
    }

    static func hasCompletedOnboarding(userDefaults: UserDefaults = .standard) -> Bool {
        return userDefaults.bool(forKey: "hasCompletedOnboarding")
    }
}
