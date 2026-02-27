import Foundation
import Supabase

// MARK: - Auth User

struct AuthUser: Sendable {
    let id: String
    let email: String?
    let provider: String
}

// MARK: - Supabase Config

private enum SupabaseConfig {
    static let shared: [String: String] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else { return [:] }
        return dict
    }()

    static var projectURL: String { shared["SUPABASE_URL"] ?? "" }
    static var anonKey: String { shared["SUPABASE_ANON_KEY"] ?? "" }
}

// MARK: - Supabase Auth Service

@Observable
final class SupabaseAuthService {
    static let shared = SupabaseAuthService()

    let client: SupabaseClient
    var currentUser: AuthUser?
    var isLoading = false
    var errorMessage: String?

    var isAuthenticated: Bool { currentUser != nil }

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.projectURL)!,
            supabaseKey: SupabaseConfig.anonKey
        )

        // Restore user from persisted session
        if let user = client.auth.currentUser {
            currentUser = Self.mapUser(user)
        }
    }

    // MARK: - Email Auth

    func signUpWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await client.auth.signUp(email: email, password: password)
            currentUser = Self.mapUser(response.user)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = try await client.auth.signIn(email: email, password: password)
            currentUser = Self.mapUser(session.user)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - OAuth (Apple / Google)

    func signInWithIdToken(idToken: String, nonce: String?, provider: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let oauthProvider: OpenIDConnectCredentials.Provider = provider == "apple" ? .apple : .google
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: oauthProvider,
                    idToken: idToken,
                    nonce: nonce
                )
            )
            currentUser = Self.mapUser(session.user)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            // Sign out locally even if server call fails
        }
        currentUser = nil
    }

    // MARK: - Refresh Session

    func refreshSession() async {
        do {
            let session = try await client.auth.session
            currentUser = Self.mapUser(session.user)
        } catch {
            currentUser = nil
        }
    }

    // MARK: - Helpers

    private static func mapUser(_ user: User) -> AuthUser {
        let provider = (try? user.appMetadata["provider"]?.decode(as: String.self)) ?? "email"
        return AuthUser(id: user.id.uuidString, email: user.email, provider: provider)
    }
}
