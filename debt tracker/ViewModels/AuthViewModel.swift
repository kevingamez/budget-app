import Foundation
import AuthenticationServices

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var isSignUp = false
    var isLoading = false
    var errorMessage: String?

    private let authService = SupabaseAuthService.shared
    private let appleService = AppleSignInService()

    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    var isFormValid: Bool {
        isEmailValid && isPasswordValid
    }

    // MARK: - Email

    func signInWithEmail() async {
        guard isFormValid else {
            errorMessage = AppStrings.shared.tr("auth.errorInvalidForm")
            return
        }

        isLoading = true
        errorMessage = nil

        if isSignUp {
            await authService.signUpWithEmail(email: email, password: password)
        } else {
            await authService.signInWithEmail(email: email, password: password)
        }

        if let error = authService.errorMessage {
            errorMessage = error
        }
        isLoading = false
    }

    // MARK: - Apple

    func signInWithApple() {
        isLoading = true
        errorMessage = nil

        appleService.signIn { [weak self] idToken, nonce in
            Task { @MainActor in
                await SupabaseAuthService.shared.signInWithIdToken(
                    idToken: idToken,
                    nonce: nonce,
                    provider: "apple"
                )
                if let error = SupabaseAuthService.shared.errorMessage {
                    self?.errorMessage = error
                }
                self?.isLoading = false
            }
        } onError: { [weak self] error in
            Task { @MainActor in
                if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                    self?.errorMessage = error.localizedDescription
                }
                self?.isLoading = false
            }
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        await authService.signOut()
    }
}
