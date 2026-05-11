import Foundation
import LocalAuthentication

/// Wraps `LAContext.evaluatePolicy` so the launch gate has a single, testable entry point.
/// Falls back to device passcode if biometrics fail or aren't enrolled — we never want to
/// strand the user out of their own data.
@Observable
final class BiometricAuthService {
    static let shared = BiometricAuthService()

    /// Last evaluation result (true = unlocked this session).
    var isUnlocked = false

    /// Friendly biometry name to show in UI prompts.
    var biometryType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return context.biometryType
    }

    private init() {}

    /// Trigger biometric (or passcode-fallback) evaluation.
    /// Returns true on success; false on cancel/failure (caller stays on the lock screen).
    @discardableResult
    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        // Allow Face ID → Touch ID → device passcode in that order.
        // `.deviceOwnerAuthentication` (not the `WithBiometrics` variant) lets the
        // user fall back to passcode if biometry fails 3× or isn't enrolled.
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            // Device has no passcode set — biometric protection isn't possible at all.
            // Don't soft-lock the user out.
            isUnlocked = true
            return true
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            isUnlocked = success
            return success
        } catch {
            isUnlocked = false
            return false
        }
    }

    /// Lock the session (call when entering background or signing out).
    func lock() {
        isUnlocked = false
    }
}
