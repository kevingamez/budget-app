import AuthenticationServices
import CryptoKit

final class AppleSignInService: NSObject, ASAuthorizationControllerDelegate {
    private var currentNonce: String?
    private var completion: ((String, String?) -> Void)?
    private var errorHandler: ((Error) -> Void)?

    func signIn(completion: @escaping (String, String?) -> Void, onError: @escaping (Error) -> Void) {
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

    // MARK: - Delegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
        errorHandler?(error)
    }

    // MARK: - Nonce

    private func randomNonceString(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
