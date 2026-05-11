import Foundation
import Supabase
import SwiftData
import os

// MARK: - Auth User

struct AuthUser: Sendable {
    let id: String
    let email: String?
    let provider: String
}

// MARK: - Supabase Config

enum SupabaseConfig {
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

    private static let log = Logger(subsystem: "kevingamez.debt-tracker", category: "auth")

    let client: SupabaseClient
    var currentUser: AuthUser?
    var isLoading = false
    var errorMessage: String?
    var initializationError: String?
    var isConfigured: Bool

    var isAuthenticated: Bool { currentUser != nil }

    private init() {
        let urlString = SupabaseConfig.projectURL
        if let url = URL(string: urlString), !urlString.isEmpty {
            client = SupabaseClient(
                supabaseURL: url,
                supabaseKey: SupabaseConfig.anonKey
            )
            isConfigured = true
            initializationError = nil

            // Restore user from persisted session
            if let user = client.auth.currentUser {
                currentUser = Self.mapUser(user)
            }
        } else {
            // Bail gracefully — do not crash on missing/invalid config.
            Self.log.error("Supabase URL missing or invalid; auth client is non-functional")
            // Construct a non-functional client with a dummy URL so the type still resolves.
            // swiftlint:disable:next force_unwrapping
            let dummy = URL(string: "https://invalid.example.com")!
            client = SupabaseClient(
                supabaseURL: dummy,
                supabaseKey: SupabaseConfig.anonKey
            )
            isConfigured = false
            initializationError = "Supabase configuration missing"
            currentUser = nil
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

    /// Sign out and wipe every piece of user-scoped local state.
    ///
    /// The `ModelContext` is **required** so SwiftData entities (debts,
    /// payments, people, categories) are deleted along with auth state.
    /// Without it the next account that signs in on this device would see
    /// the previous user's debts — a cross-account leak. There used to be a
    /// `modelContext: ModelContext? = nil` overload; it was removed because
    /// nothing in the app should sign out without holding a context.
    func signOut(modelContext: ModelContext) async {
        do {
            try await client.auth.signOut()
        } catch {
            // Sign out locally even if server call fails.
            Self.log.error("Server sign-out failed: \(String(describing: error), privacy: .public)")
        }
        currentUser = nil

        // Best-effort local cleanup of user-scoped state.
        NotificationService.shared.cancelAllReminders()
        ProfilePhotoStorage.delete()
        BiometricAuthService.shared.lock()

        do {
            // Order matters for cascade rules: delete dependents first.
            try modelContext.delete(model: Payment.self)
            try modelContext.delete(model: Debt.self)
            try modelContext.delete(model: Person.self)
            try modelContext.delete(model: DebtCategory.self)
            try modelContext.save()
        } catch {
            Self.log.error("SwiftData wipe on signOut failed: \(String(describing: error), privacy: .public)")
        }

        // Clear user-scoped UserDefaults: profile-tied keys, security pref, AI
        // consent, AI rate-limit counters, and any cached AI insights. App-wide
        // appearance prefs (language, currency, theme, direction) stay so the
        // next sign-in lands on the same look-and-feel.
        let defaults = UserDefaults.standard
        let userScopedKeys = [
            "userName",
            "requireBiometrics",
            AIConsent.key,
            "ai_insights_daily_count",
            "ai_insights_daily_day",
        ]
        for key in userScopedKeys {
            defaults.removeObject(forKey: key)
        }
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("ai_insights_cache") {
            defaults.removeObject(forKey: key)
        }
    }

    // MARK: - Refresh Session

    func refreshSession() async {
        do {
            let session = try await client.auth.session
            currentUser = Self.mapUser(session.user)
        } catch {
            // Only clear currentUser on auth-level errors (401). Transport/network errors
            // should NOT log the user out — keep their session and try again later.
            if let urlError = error as? URLError {
                Self.log.error("Refresh transport error \(urlError.code.rawValue, privacy: .public): \(urlError.localizedDescription, privacy: .public)")
                // leave currentUser untouched
                return
            }

            let nsError = error as NSError
            let isAuthError = nsError.code == 401
                || nsError.localizedDescription.localizedCaseInsensitiveContains("unauthor")
                || nsError.localizedDescription.localizedCaseInsensitiveContains("invalid token")
                || nsError.localizedDescription.localizedCaseInsensitiveContains("jwt")

            if isAuthError {
                Self.log.error("Refresh auth error — clearing currentUser: \(String(describing: error), privacy: .public)")
                currentUser = nil
            } else {
                Self.log.error("Refresh non-auth error — keeping currentUser: \(String(describing: error), privacy: .public)")
                // leave currentUser untouched on ambiguous errors
            }
        }
    }

    // MARK: - Helpers

    private static func mapUser(_ user: User) -> AuthUser {
        let provider = (try? user.appMetadata["provider"]?.decode(as: String.self)) ?? "email"
        return AuthUser(id: user.id.uuidString, email: user.email, provider: provider)
    }
}
