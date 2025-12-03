import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingState = OnboardingState()
    @StateObject private var sensitiveAppManager = SensitiveAppManager()
    @State private var isPermissionGranted: Bool = false
    @State private var isCheckingPermission = false
    @State private var permissionCheckTimer: Timer?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header with progress
            headerView

            Divider()

            // Main content area
            TabView(selection: $onboardingState.currentStep) {
                welcomeStep
                    .tag(OnboardingStep.welcome)

                permissionsStep
                    .tag(OnboardingStep.permissions)

                shortcutStep
                    .tag(OnboardingStep.shortcut)

                privacyStep
                    .tag(OnboardingStep.privacy)

                tipsStep
                    .tag(OnboardingStep.tips)
            }
            .tabViewStyle(.automatic)
            .frame(height: 400)

            Divider()

            // Navigation footer
            navigationFooter
        }
        .frame(width: 500, height: 550)
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 12) {
            // Step indicator
            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    Circle()
                        .fill(step.rawValue <= onboardingState.currentStepIndex ? Color.swiftClipPrimary : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }

            // Progress bar
            ProgressView(value: onboardingState.progress)
                .progressViewStyle(.linear)
                .tint(.swiftClipPrimary)
                .frame(width: 200)

            // Step title
            Text("\(onboardingState.currentStepIndex + 1) / \(OnboardingStep.allCases.count)")
                .swiftClipCaptionSmall()
                .foregroundColor(.swiftClipTextSecondary)
        }
        .padding()
    }

    // MARK: - Navigation Footer

    private var navigationFooter: some View {
        HStack {
            // Back button
            if onboardingState.canGoPrevious {
                Button(action: {
                    withAnimation {
                        onboardingState.previousStep()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .swiftClipBody()
                    .foregroundColor(.swiftClipTextSecondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Next/Finish button
            if onboardingState.isLastStep {
                Button(action: finishOnboarding) {
                    HStack {
                        Text("Start Using SwiftClip")
                            .swiftClipBodyMedium()
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.swiftClipPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    withAnimation {
                        onboardingState.nextStep()
                    }
                }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .swiftClipBodyMedium()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.swiftClipPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: onboardingState.currentStep.icon)
                .font(.system(size: 80))
                .foregroundColor(.swiftClipPrimary)

            // Title and subtitle
            VStack(spacing: 8) {
                Text(onboardingState.currentStep.title)
                    .swiftClipTitleBold()
                    .foregroundColor(.swiftClipPrimary)

                Text(onboardingState.currentStep.subtitle)
                    .swiftClipBody()
                    .foregroundColor(.swiftClipTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Feature highlights
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "clock.arrow.circlepath", text: "Unlimited clipboard history")
                FeatureRow(icon: "magnifyingglass", text: "Instant search across all items")
                FeatureRow(icon: "pin.fill", text: "Pin important items")
                FeatureRow(icon: "hand.raised.shield", text: "Privacy-focused design")
            }
            .padding()
            .background(Color.swiftClipBackground.opacity(0.5))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
    }

    // MARK: - Step 2: Permissions

    private var permissionsStep: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: onboardingState.currentStep.icon)
                .font(.system(size: 60))
                .foregroundColor(.swiftClipPrimary)

            // Title and subtitle
            VStack(spacing: 8) {
                Text(onboardingState.currentStep.title)
                    .swiftClipHeadline()
                    .foregroundColor(.swiftClipText)

                Text(onboardingState.currentStep.subtitle)
                    .swiftClipBody()
                    .foregroundColor(.swiftClipTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Divider()

            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                InstructionRow(number: "1", title: "Click 'Open System Settings'", description: "Opens Privacy & Security settings")
                InstructionRow(number: "2", title: "Find SwiftClip in the list", description: "Scroll down if needed")
                InstructionRow(number: "3", title: "Toggle the checkbox", description: "Enable SwiftClip access")
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button(action: openSystemSettings) {
                    HStack {
                        Image(systemName: "lock.shield")
                        Text("Open System Settings")
                            .swiftClipBodyMedium()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.swiftClipPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                if isCheckingPermission {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Checking permission...")
                            .swiftClipCaption()
                            .foregroundColor(.swiftClipTextSecondary)
                    }
                } else {
                    Button(action: recheckPermission) {
                        Text("I've Granted Permission")
                            .swiftClipBody()
                            .foregroundColor(.swiftClipPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Permission persists across app updates")
                .swiftClipCaption()
                .foregroundColor(.swiftClipTextSecondary)
        }
        .padding()
    }

    // MARK: - Step 3: Shortcut

    private var shortcutStep: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: onboardingState.currentStep.icon)
                .font(.system(size: 60))
                .foregroundColor(.swiftClipPrimary)

            // Title and subtitle
            VStack(spacing: 8) {
                Text(onboardingState.currentStep.title)
                    .swiftClipHeadline()
                    .foregroundColor(.swiftClipText)

                Text(onboardingState.currentStep.subtitle)
                    .swiftClipBody()
                    .foregroundColor(.swiftClipTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Divider()

            // Default shortcut display
            VStack(spacing: 16) {
                Text("Default Shortcut")
                    .swiftClipBodyMedium()
                    .foregroundColor(.swiftClipText)

                HStack(spacing: 8) {
                    KeyCapView(text: "⌥")
                    Text("+")
                        .swiftClipBody()
                    KeyCapView(text: "V")
                }

                Text("Press Option + V anywhere to open SwiftClip")
                    .swiftClipCaption()
                    .foregroundColor(.swiftClipTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.swiftClipBackground.opacity(0.5))
            .cornerRadius(8)

            Spacer()

            // Info box
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.swiftClipPrimary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("You can change this shortcut later")
                        .swiftClipCaption()
                        .foregroundColor(.swiftClipText)
                    Text("Go to Settings → Keyboard")
                        .swiftClipCaptionSmall()
                        .foregroundColor(.swiftClipTextSecondary)
                }
            }
            .padding()
            .background(Color.swiftClipPrimary.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
    }

    // MARK: - Step 4: Privacy

    private var privacyStep: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: onboardingState.currentStep.icon)
                .font(.system(size: 60))
                .foregroundColor(.swiftClipPrimary)

            // Title and subtitle
            VStack(spacing: 8) {
                Text(onboardingState.currentStep.title)
                    .swiftClipHeadline()
                    .foregroundColor(.swiftClipText)

                Text(onboardingState.currentStep.subtitle)
                    .swiftClipBody()
                    .foregroundColor(.swiftClipTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Divider()

            // Privacy settings
            VStack(alignment: .leading, spacing: 16) {
                // Auto-detect toggle
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Auto-detect sensitive apps", isOn: $sensitiveAppManager.isAutoDetectEnabled)
                        .swiftClipBody()
                        .tint(.swiftClipPrimary)

                    Text("Automatically excludes clipboard content from password managers")
                        .swiftClipCaption()
                        .foregroundColor(.swiftClipTextSecondary)
                }

                Divider()

                // Protected apps info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.swiftClipAccent)
                        Text("Protected by Default")
                            .swiftClipBodyMedium()
                    }

                    Text("\(SensitiveAppManager.defaultSensitiveApps.count) password managers and sensitive apps")
                        .swiftClipCaption()
                        .foregroundColor(.swiftClipTextSecondary)

                    Text("Includes: 1Password, Bitwarden, Dashlane, LastPass, and more")
                        .swiftClipCaptionSmall()
                        .foregroundColor(.swiftClipTextSecondary)
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)

            Spacer()

            // Info box
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.swiftClipPrimary)
                Text("You can customize excluded apps in Settings later")
                    .swiftClipCaption()
                    .foregroundColor(.swiftClipText)
            }
            .padding()
            .background(Color.swiftClipPrimary.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
    }

    // MARK: - Step 5: Tips

    private var tipsStep: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: onboardingState.currentStep.icon)
                .font(.system(size: 60))
                .foregroundColor(.swiftClipAccent)

            // Title and subtitle
            VStack(spacing: 8) {
                Text(onboardingState.currentStep.title)
                    .swiftClipHeadline()
                    .foregroundColor(.swiftClipText)

                Text(onboardingState.currentStep.subtitle)
                    .swiftClipBody()
                    .foregroundColor(.swiftClipTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Divider()

            // Tips list
            VStack(alignment: .leading, spacing: 16) {
                TipRow(
                    icon: "pin.fill",
                    title: "Pin Important Items",
                    description: "Click the pin icon to keep items at the top"
                )

                TipRow(
                    icon: "doc.plaintext",
                    title: "Paste as Plain Text",
                    description: "Right-click any item for paste options"
                )

                TipRow(
                    icon: "magnifyingglass",
                    title: "Search Instantly",
                    description: "Start typing to filter your clipboard history"
                )

                TipRow(
                    icon: "keyboard",
                    title: "Use Arrow Keys",
                    description: "Navigate with ↑/↓ and press Enter to paste"
                )
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)

            Spacer()

            // Ready message
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.swiftClipAccent)
                    .font(.title2)
                Text("You're all set! Press 'Start Using SwiftClip' below.")
                    .swiftClipBody()
                    .foregroundColor(.swiftClipText)
            }
            .padding()
            .background(Color.swiftClipAccent.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
    }

    // MARK: - Helper Methods

    private func openSystemSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)

        // Auto-check permission
        isCheckingPermission = true
        var checkCount = 0
        let maxChecks = 15

        permissionCheckTimer?.invalidate()
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            checkCount += 1
            if checkPermission() || checkCount >= maxChecks {
                timer.invalidate()
                isCheckingPermission = false
                permissionCheckTimer = nil
            }
        }
    }

    private func recheckPermission() {
        isCheckingPermission = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            _ = checkPermission()
            isCheckingPermission = false
        }
    }

    private func checkPermission() -> Bool {
        let granted = AccessibilityPermissionManager.shared.isPermissionGranted()
        isPermissionGranted = granted

        if granted {
            // Auto-advance to next step
            DispatchQueue.main.async {
                withAnimation {
                    onboardingState.nextStep()
                }
            }
        }

        return granted
    }

    private func finishOnboarding() {
        OnboardingState.markAsCompleted()
        dismiss()
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.swiftClipPrimary)
                .frame(width: 24)
            Text(text)
                .swiftClipBody()
                .foregroundColor(.swiftClipText)
        }
    }
}

struct InstructionRow: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.swiftClipPrimary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .swiftClipBodyMedium()
                Text(description)
                    .swiftClipCaption()
                    .foregroundColor(.swiftClipTextSecondary)
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.swiftClipAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .swiftClipBodyMedium()
                Text(description)
                    .swiftClipCaption()
                    .foregroundColor(.swiftClipTextSecondary)
            }
        }
    }
}

struct KeyCapView: View {
    let text: String

    var body: some View {
        Text(text)
            .swiftClipTitleBold()
            .foregroundColor(.swiftClipText)
            .frame(width: 50, height: 50)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

#Preview {
    OnboardingView()
}
