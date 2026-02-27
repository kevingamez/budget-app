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
            URLQueryItem(name: "response_type", value: "code"),
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

            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let accessToken = components.queryItems?.first(where: { $0.name == "access_token" })?.value
            else {
                completion(.failure(NSError(domain: "google", code: -3, userInfo: [NSLocalizedDescriptionKey: "No token in callback"])))
                return
            }

            let idToken = components.queryItems?.first(where: { $0.name == "id_token" })?.value ?? accessToken
            completion(.success((idToken: idToken, accessToken: accessToken)))
        }

        session?.presentationContextProvider = anchor
        session?.prefersEphemeralWebBrowserSession = false
        session?.start()
    }
}
