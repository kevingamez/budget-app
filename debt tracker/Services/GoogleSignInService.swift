import AuthenticationServices
import CryptoKit
import Foundation

/// Google Sign In via OIDC implicit flow (`response_type=id_token`).
/// Hardened with `state` (CSRF), `nonce` (replay), strict id_token requirement,
/// ephemeral browser session (no Safari cookie persistence), and the OIDC-mandated
/// `nonce` parameter included in the id_token claims.
final class GoogleSignInService {
    private var session: ASWebAuthenticationSession?
    private var pendingState: String?
    private var pendingNonce: String?

    enum SignInError: Error {
        case notConfigured
        case invalidAuthURL
        case noCallback
        case stateMismatch
        case missingIdToken
        case underlying(Error)
    }

    func signIn(
        presenting anchor: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (Result<(idToken: String, nonce: String), SignInError>) -> Void
    ) {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String,
              !clientId.isEmpty,
              let supabaseURL = secretsValue(forKey: "SUPABASE_URL")
        else {
            completion(.failure(.notConfigured))
            return
        }

        let redirectURI = "\(supabaseURL)/auth/v1/callback"
        let scope = "openid email profile"
        let state = Self.randomURLSafeString(length: 32)
        let nonce = Self.randomURLSafeString(length: 32)
        // OIDC requires the nonce to appear in the id_token; we send the raw value
        // because Google's implicit flow doesn't take a hashed nonce like Apple does.
        pendingState = state
        pendingNonce = nonce

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "id_token"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "nonce", value: nonce),
            URLQueryItem(name: "prompt", value: "select_account"),
        ]

        guard let authURL = components.url else {
            completion(.failure(.invalidAuthURL))
            return
        }

        let scheme = URL(string: supabaseURL)?.host?.components(separatedBy: ".").first

        session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { [weak self] callbackURL, error in
            self?.handleCallback(callbackURL: callbackURL, error: error, completion: completion)
        }

        session?.presentationContextProvider = anchor
        // Don't reuse Safari cookies — every sign-in starts fresh.
        session?.prefersEphemeralWebBrowserSession = true
        session?.start()
    }

    private func handleCallback(
        callbackURL: URL?,
        error: Error?,
        completion: (Result<(idToken: String, nonce: String), SignInError>) -> Void
    ) {
        defer {
            pendingState = nil
            pendingNonce = nil
        }

        if let error {
            completion(.failure(.underlying(error)))
            return
        }

        guard let callbackURL else {
            completion(.failure(.noCallback))
            return
        }

        // Implicit-flow params come back in the URL fragment.
        let pairs = parseFragment(callbackURL.fragment ?? "")

        // CSRF check.
        guard let returnedState = pairs["state"],
              let expectedState = pendingState,
              returnedState == expectedState else {
            completion(.failure(.stateMismatch))
            return
        }

        // OIDC: must have id_token. We deliberately do NOT fall back to
        // `access_token` — that would let an attacker who can supply only an
        // access_token impersonate via the wrong identity token.
        guard let idToken = pairs["id_token"], let nonce = pendingNonce else {
            completion(.failure(.missingIdToken))
            return
        }

        completion(.success((idToken: idToken, nonce: nonce)))
    }

    private func parseFragment(_ fragment: String) -> [String: String] {
        // URLComponents handles edge cases (multiple `=`, percent encoding) better
        // than manual splitting, and keeps us out of the brittle string-arithmetic business.
        guard let items = URLComponents(string: "?\(fragment)")?.queryItems else { return [:] }
        return items.reduce(into: [String: String]()) { acc, item in
            if let value = item.value { acc[item.name] = value }
        }
    }

    private func secretsValue(forKey key: String) -> String? {
        Bundle.main.url(forResource: "Secrets", withExtension: "plist")
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? PropertyListSerialization.propertyList(from: $0, format: nil) as? [String: String] }?[key]
    }

    /// URL-safe base64 random string.
    private static func randomURLSafeString(length: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        precondition(status == errSecSuccess, "SecRandomCopyBytes failed: \(status)")
        return Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
