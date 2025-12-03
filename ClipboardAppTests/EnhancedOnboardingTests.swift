import XCTest
import SwiftUI
@testable import ClipboardApp

final class EnhancedOnboardingTests: XCTestCase {

    // MARK: - OnboardingStep Enum Tests

    func testOnboardingStepCount() {
        // Given/When
        let steps = OnboardingStep.allCases

        // Then
        XCTAssertEqual(steps.count, 5, "Should have 5 onboarding steps")
    }

    func testOnboardingStepOrder() {
        // Given/When
        let steps = OnboardingStep.allCases

        // Then
        XCTAssertEqual(steps[0], .welcome)
        XCTAssertEqual(steps[1], .permissions)
        XCTAssertEqual(steps[2], .shortcut)
        XCTAssertEqual(steps[3], .privacy)
        XCTAssertEqual(steps[4], .tips)
    }

    func testWelcomeStepProperties() {
        // Given
        let step = OnboardingStep.welcome

        // Then
        XCTAssertEqual(step.title, "Welcome to SwiftClip")
        XCTAssertEqual(step.icon, "doc.on.clipboard.fill")
        XCTAssertFalse(step.subtitle.isEmpty)
        XCTAssertTrue(step.subtitle.contains("clipboard"))
    }

    func testPermissionsStepProperties() {
        // Given
        let step = OnboardingStep.permissions

        // Then
        XCTAssertEqual(step.title, "Accessibility Permission")
        XCTAssertEqual(step.icon, "lock.shield")
        XCTAssertFalse(step.subtitle.isEmpty)
    }

    func testShortcutStepProperties() {
        // Given
        let step = OnboardingStep.shortcut

        // Then
        XCTAssertEqual(step.title, "Keyboard Shortcut")
        XCTAssertEqual(step.icon, "command")
        XCTAssertFalse(step.subtitle.isEmpty)
    }

    func testPrivacyStepProperties() {
        // Given
        let step = OnboardingStep.privacy

        // Then
        XCTAssertEqual(step.title, "Privacy Settings")
        XCTAssertEqual(step.icon, "hand.raised.shield")
        XCTAssertFalse(step.subtitle.isEmpty)
    }

    func testTipsStepProperties() {
        // Given
        let step = OnboardingStep.tips

        // Then
        XCTAssertEqual(step.title, "Quick Tips")
        XCTAssertEqual(step.icon, "lightbulb.fill")
        XCTAssertFalse(step.subtitle.isEmpty)
    }

    // MARK: - Navigation Tests

    func testOnboardingStateInitializesAtWelcome() {
        // Given/When
        let state = OnboardingState()

        // Then
        XCTAssertEqual(state.currentStep, .welcome)
        XCTAssertEqual(state.currentStepIndex, 0)
    }

    func testNextStepAdvancesCorrectly() {
        // Given
        let state = OnboardingState()

        // When
        state.nextStep()

        // Then
        XCTAssertEqual(state.currentStep, .permissions)
        XCTAssertEqual(state.currentStepIndex, 1)
    }

    func testPreviousStepMovesBackCorrectly() {
        // Given
        let state = OnboardingState()
        state.nextStep() // Move to permissions

        // When
        state.previousStep()

        // Then
        XCTAssertEqual(state.currentStep, .welcome)
        XCTAssertEqual(state.currentStepIndex, 0)
    }

    func testPreviousStepDoesNotGoBeforeFirst() {
        // Given
        let state = OnboardingState()

        // When
        state.previousStep()

        // Then
        XCTAssertEqual(state.currentStep, .welcome)
        XCTAssertEqual(state.currentStepIndex, 0)
    }

    func testNextStepDoesNotGoAfterLast() {
        // Given
        let state = OnboardingState()

        // When - advance to last step
        for _ in 0..<10 {
            state.nextStep()
        }

        // Then
        XCTAssertEqual(state.currentStep, .tips)
        XCTAssertEqual(state.currentStepIndex, 4)
    }

    func testGoToStepDirectly() {
        // Given
        let state = OnboardingState()

        // When
        state.goToStep(.privacy)

        // Then
        XCTAssertEqual(state.currentStep, .privacy)
        XCTAssertEqual(state.currentStepIndex, 3)
    }

    func testCanGoNextReturnsTrueBeforeLastStep() {
        // Given
        let state = OnboardingState()

        // Then
        XCTAssertTrue(state.canGoNext)
    }

    func testCanGoNextReturnsFalseAtLastStep() {
        // Given
        let state = OnboardingState()
        state.goToStep(.tips)

        // Then
        XCTAssertFalse(state.canGoNext)
    }

    func testCanGoPreviousReturnsFalseAtFirstStep() {
        // Given
        let state = OnboardingState()

        // Then
        XCTAssertFalse(state.canGoPrevious)
    }

    func testCanGoPreviousReturnsTrueAfterFirstStep() {
        // Given
        let state = OnboardingState()
        state.nextStep()

        // Then
        XCTAssertTrue(state.canGoPrevious)
    }

    func testIsFirstStepReturnsTrueAtWelcome() {
        // Given
        let state = OnboardingState()

        // Then
        XCTAssertTrue(state.isFirstStep)
    }

    func testIsLastStepReturnsTrueAtTips() {
        // Given
        let state = OnboardingState()
        state.goToStep(.tips)

        // Then
        XCTAssertTrue(state.isLastStep)
    }

    func testProgressReturnsCorrectFraction() {
        // Given
        let state = OnboardingState()

        // When/Then
        XCTAssertEqual(state.progress, 0.0, accuracy: 0.01) // 0/4

        state.nextStep()
        XCTAssertEqual(state.progress, 0.25, accuracy: 0.01) // 1/4

        state.nextStep()
        XCTAssertEqual(state.progress, 0.50, accuracy: 0.01) // 2/4

        state.nextStep()
        XCTAssertEqual(state.progress, 0.75, accuracy: 0.01) // 3/4

        state.nextStep()
        XCTAssertEqual(state.progress, 1.0, accuracy: 0.01) // 4/4
    }

    // MARK: - Completion Tests

    func testOnboardingCompletionSavesToUserDefaults() {
        // Given
        let userDefaults = UserDefaults(suiteName: "test-onboarding")!
        userDefaults.removeObject(forKey: "hasCompletedOnboarding")

        // When
        OnboardingState.markAsCompleted(userDefaults: userDefaults)

        // Then
        let completed = userDefaults.bool(forKey: "hasCompletedOnboarding")
        XCTAssertTrue(completed)
    }

    func testHasCompletedOnboardingReturnsFalseByDefault() {
        // Given
        let userDefaults = UserDefaults(suiteName: "test-onboarding-2")!
        userDefaults.removeObject(forKey: "hasCompletedOnboarding")

        // When/Then
        XCTAssertFalse(OnboardingState.hasCompletedOnboarding(userDefaults: userDefaults))
    }

    func testHasCompletedOnboardingReturnsTrueAfterCompletion() {
        // Given
        let userDefaults = UserDefaults(suiteName: "test-onboarding-3")!
        userDefaults.removeObject(forKey: "hasCompletedOnboarding")

        // When
        OnboardingState.markAsCompleted(userDefaults: userDefaults)

        // Then
        XCTAssertTrue(OnboardingState.hasCompletedOnboarding(userDefaults: userDefaults))
    }
}
