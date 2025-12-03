import SwiftUI

struct OnboardingView: View {
    @State private var isPermissionGranted: Bool = false
    @State private var isCheckingPermission = false
    @State private var permissionCheckTimer: Timer?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // App Icon
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 60))
                .foregroundColor(.swiftClipPrimary)

            // Welcome
            VStack(spacing: 8) {
                Text("Welcome to SwiftClip")
                    .swiftClipTitleBold()
                    .foregroundColor(.swiftClipPrimary)

                Text("Your clipboard, smarter and faster.")
                    .swiftClipBody()
                    .foregroundColor(.swiftClipTextSecondary)
            }

            Divider()

            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                InstructionRow(number: "1", title: "Grant Accessibility Permission", description: "Required to capture keyboard shortcuts")
                InstructionRow(number: "2", title: "Press Option+V Anytime", description: "Your clipboard history appears instantly")
                InstructionRow(number: "3", title: "Click to Paste", description: "Items automatically paste into your app")
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)

            Spacer()

            // Action Button
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
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(32)
        .frame(width: 450, height: 550)
    }

    private func openSystemSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)

        // Auto-check permission every 2 seconds for max 30 seconds
        isCheckingPermission = true
        var checkCount = 0
        let maxChecks = 15 // 15 checks * 2 seconds = 30 seconds

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
            // Close the onboarding window
            DispatchQueue.main.async {
                NSApplication.shared.windows.first(where: { $0.title == "Setup" })?.close()
            }
        }

        return granted
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
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
