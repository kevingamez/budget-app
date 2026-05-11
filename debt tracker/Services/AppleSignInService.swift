import AuthenticationServices
import CryptoKit

final class AppleSignInService: NSObject, ASAuthorizationControllerDelegate {
    static let shared = AppleSignInService()

    private var currentNonce: String?
    private var completion: ((String, String?) -> Void)?
    private var errorHandler: ((Error) -> Void)?

    func signIn(completion: @escaping (String, String?) -> Void, onError: @escaping (Error) -> Void) {
        // Guard re-entry: if a sign-in is already pending, fail the previous
        // completion before reassigning so the prior caller isn't left hanging.
        if self.completion != nil {
            self.errorHandler?(NSError(
                domain: "AppleSignIn",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "superseded"]
            ))
            self.completion = nil
            self.errorHandler = nil
        }

        self.completion = completion
        self.errorHandler = onError

        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    /// Public hook so a SwiftUI `SignInWithAppleButton` can configure its
    /// request with the same hashed nonce that the service expects to verify.
    ///
    /// **Always generates a fresh nonce.** The nonce is a per-request,
    /// single-use anti-replay token; reusing one across sessions would let an
    /// attacker who captured a prior identity token replay it against the
    /// auth server. SwiftUI may invoke `onRequest` again after a cancel or a
    /// re-tap, and we want each of those attempts to mint a new value.
    func currentNonceHash() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    /// Raw (unhashed) nonce, used when forwarding the identity token to Supabase.
    func currentRawNonce() -> String? { currentNonce }

    /// Clear the nonce + completion handlers. Callers must invoke this from
    /// every terminal path of the Sign in with Apple flow (success, failure,
    /// cancellation) so a stale nonce can't be reused by a subsequent
    /// attacker-controlled flow.
    func clearNonce() {
        currentNonce = nil
    }

    /// Allow callers (e.g. SwiftUI's `SignInWithAppleButton`) to register
    /// completion handlers when they own the request lifecycle.
    func setHandlers(
        completion: @escaping (String, String?) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        if self.completion != nil {
            self.errorHandler?(NSError(
                domain: "AppleSignIn",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "superseded"]
            ))
        }
        self.completion = completion
        self.errorHandler = onError
    }

    /// Process a result from a SwiftUI `SignInWithAppleButton.onCompletion` callback.
    func handle(result: Result<ASAuthorization, Error>) {
        defer { resetState() }
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8)
            else {
                errorHandler?(NSError(domain: "apple", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get Apple ID token"]))
                return
            }
            completion?(idToken, currentNonce)
        case .failure(let error):
            errorHandler?(error)
        }
    }

    // MARK: - Delegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { resetState() }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8)
        else {
            errorHandler?(NSError(domain: "apple", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get Apple ID token"]))
            return
        }
        completion?(idToken, currentNonce)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer { resetState() }
        errorHandler?(error)
    }

    /// Clear nonce + handlers after a sign-in attempt finishes. Run from
    /// every terminal path so a stale nonce can't be replayed.
    private func resetState() {
        currentNonce = nil
        completion = nil
        errorHandler = nil
    }

    // MARK: - Nonce

    private func randomNonceString(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        // Surface entropy-pool failures loudly — silently returning zeroed
        // bytes would weaken the OIDC nonce to a constant.
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        precondition(status == errSecSuccess, "SecRandomCopyBytes failed: \(status)")
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
