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
    /// Generates a fresh nonce if one is not already set.
    func currentNonceHash() -> String {
        if currentNonce == nil {
            currentNonce = randomNonceString()
        }
        return sha256(currentNonce ?? "")
    }

    /// Raw (unhashed) nonce, used when forwarding the identity token to Supabase.
    func currentRawNonce() -> String? { currentNonce }

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
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8)
            else {
                errorHandler?(NSError(domain: "apple", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get Apple ID token"]))
                completion = nil
                errorHandler = nil
                return
            }
            completion?(idToken, currentNonce)
            completion = nil
            errorHandler = nil
        case .failure(let error):
            errorHandler?(error)
            completion = nil
            errorHandler = nil
        }
    }

    // MARK: - Delegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8)
        else {
            errorHandler?(NSError(domain: "apple", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get Apple ID token"]))
            completion = nil
            errorHandler = nil
            return
        }
        completion?(idToken, currentNonce)
        completion = nil
        errorHandler = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorHandler?(error)
        completion = nil
        errorHandler = nil
    }

    // MARK: - Nonce

    private func randomNonceString(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
