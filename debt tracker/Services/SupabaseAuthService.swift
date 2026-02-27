import Foundation
import Security

// MARK: - Auth User

struct AuthUser: Sendable {
    let id: String
    let email: String?
    let provider: String
}

// MARK: - Keychain Token Storage

private enum AuthKeychain {
    private static let service = "kevingamez.debt-tracker.auth"

    static func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)
        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    static func load(_ key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func clearAll() {
        delete("access_token")
        delete("refresh_token")
        delete("user_id")
        delete("user_email")
        delete("user_provider")
    }
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

    var currentUser: AuthUser?
    var isLoading = false
    var errorMessage: String?

    var isAuthenticated: Bool { currentUser != nil }

    private init() {
        restoreSession()
    }

    // MARK: - Email Auth

    func signUpWithEmail(email: String, password: String) async {
        await performAuth {
            let url = URL(string: "\(SupabaseConfig.projectURL)/auth/v1/signup")!
            let body: [String: String] = ["email": email, "password": password]
            return try await self.authRequest(url: url, body: body)
        }
    }

    func signInWithEmail(email: String, password: String) async {
        await performAuth {
            let url = URL(string: "\(SupabaseConfig.projectURL)/auth/v1/token?grant_type=password")!
            let body: [String: String] = ["email": email, "password": password]
            return try await self.authRequest(url: url, body: body)
        }
    }

    // MARK: - OAuth (Apple / Google)

    func signInWithIdToken(idToken: String, nonce: String?, provider: String) async {
        await performAuth {
            let url = URL(string: "\(SupabaseConfig.projectURL)/auth/v1/token?grant_type=id_token")!
            var body: [String: String] = ["provider": provider, "id_token": idToken]
            if let nonce = nonce { body["nonce"] = nonce }
            return try await self.authRequest(url: url, body: body)
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        guard let token = AuthKeychain.load("access_token") else {
            clearSession()
            return
        }

        var request = URLRequest(url: URL(string: "\(SupabaseConfig.projectURL)/auth/v1/logout")!)
        request.httpMethod = "POST"
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        _ = try? await URLSession.shared.data(for: request)

        clearSession()
    }

    // MARK: - Refresh Session

    func refreshSession() async {
        guard let refreshToken = AuthKeychain.load("refresh_token") else { return }

        let url = URL(string: "\(SupabaseConfig.projectURL)/auth/v1/token?grant_type=refresh_token")!
        let body = ["refresh_token": refreshToken]

        do {
            let json = try await authRequest(url: url, body: body)
            saveSession(json)
        } catch {
            clearSession()
        }
    }

    // MARK: - Private

    private func performAuth(_ action: @escaping () async throws -> [String: Any]) async {
        isLoading = true
        errorMessage = nil

        do {
            let json = try await action()
            saveSession(json)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func authRequest(url: URL, body: [String: String]) async throws -> [String: Any] {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }

        if http.statusCode >= 400 {
            let message = json["error_description"] as? String
                ?? json["msg"] as? String
                ?? json["message"] as? String
                ?? "Authentication failed"
            throw NSError(domain: "auth", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        return json
    }

    private func saveSession(_ json: [String: Any]) {
        if let accessToken = json["access_token"] as? String {
            AuthKeychain.save(accessToken, forKey: "access_token")
        }
        if let refreshToken = json["refresh_token"] as? String {
            AuthKeychain.save(refreshToken, forKey: "refresh_token")
        }

        if let user = json["user"] as? [String: Any] {
            let id = user["id"] as? String ?? ""
            let email = user["email"] as? String
            let provider = (user["app_metadata"] as? [String: Any])?["provider"] as? String ?? "email"

            AuthKeychain.save(id, forKey: "user_id")
            if let email = email { AuthKeychain.save(email, forKey: "user_email") }
            AuthKeychain.save(provider, forKey: "user_provider")

            currentUser = AuthUser(id: id, email: email, provider: provider)
        }
    }

    private func restoreSession() {
        guard let userId = AuthKeychain.load("user_id") else { return }
        let email = AuthKeychain.load("user_email")
        let provider = AuthKeychain.load("user_provider") ?? "email"
        currentUser = AuthUser(id: userId, email: email, provider: provider)
    }

    private func clearSession() {
        AuthKeychain.clearAll()
        currentUser = nil
    }
}
