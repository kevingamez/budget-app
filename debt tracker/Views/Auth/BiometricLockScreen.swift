import SwiftUI
import LocalAuthentication

private let S = AppStrings.shared

/// Full-screen overlay shown while the app waits for biometric (or passcode) unlock.
struct BiometricLockScreen: View {
    let onUnlock: () -> Void

    private var iconName: String {
        switch BiometricAuthService.shared.biometryType {
        case .faceID: "faceid"
        case .touchID: "touchid"
        default: "lock.shield.fill"
        }
    }

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: iconName)
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(ColorTokens.primaryAccent)

                Text(S.tr("biometric.locked.title"))
                    .font(AppTypography.title2)
                    .foregroundStyle(ColorTokens.textPrimary)

                Text(S.tr("biometric.locked.subtitle"))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    Task { await attemptUnlock() }
                } label: {
                    Text(S.tr("biometric.locked.unlock"))
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(ColorTokens.primaryGradient, in: Capsule())
                }
                .pressable()
            }
        }
        .task { await attemptUnlock() }
    }

    private func attemptUnlock() async {
        let reason = S.tr("biometric.reason")
        let ok = await BiometricAuthService.shared.authenticate(reason: reason)
        if ok { onUnlock() }
    }
}
