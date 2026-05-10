import AuthenticationServices

final class GoogleSignInService {
    private var session: ASWebAuthenticationSession?

    func signIn(presenting anchor: ASWebAuthenticationPresentationContextProviding, completion: @escaping (Result<(idToken: String, accessToken: String), Error>) -> Void) {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String,
              !clientId.isEmpty,
              let supabaseURL = Bundle.main.url(forResource: "Secrets", withExtension: "plist")
                .flatMap({ try? Data(contentsOf: $0) })
                .flatMap({ try? PropertyListSerialization.propertyList(from: $0, format: nil) as? [String: String] })?["SUPABASE_URL"]
        else {
            completion(.failure(NSError(domain: "google", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign In not configured"])))
            return
        }

        let redirectURI = "\(supabaseURL)/auth/v1/callback"
        let scope = "openid email profile"

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "select_account"),
        ]

        guard let authURL = components.url else {
            completion(.failure(NSError(domain: "google", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid auth URL"])))
            return
        }

        let scheme = URL(string: supabaseURL)?.host?.components(separatedBy: ".").first

        session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { callbackURL, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let callbackURL = callbackURL else {
                completion(.failure(NSError(domain: "google", code: -3, userInfo: [NSLocalizedDescriptionKey: "No token in callback"])))
                return
            }

            // Implicit-flow tokens come back in the URL fragment, not the query string.
            let fragment = callbackURL.fragment ?? ""
            let pairs = fragment.split(separator: "&").reduce(into: [String: String]()) { acc, pair in
                let parts = pair.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    acc[String(parts[0])] = String(parts[1]).removingPercentEncoding ?? String(parts[1])
                }
            }

            guard let accessToken = pairs["access_token"] else {
                completion(.failure(NSError(domain: "google", code: -3, userInfo: [NSLocalizedDescriptionKey: "No token in callback"])))
                return
            }

            let idToken = pairs["id_token"] ?? accessToken
            completion(.success((idToken: idToken, accessToken: accessToken)))
        }

        session?.presentationContextProvider = anchor
        session?.prefersEphemeralWebBrowserSession = false
        session?.start()
    }
}
