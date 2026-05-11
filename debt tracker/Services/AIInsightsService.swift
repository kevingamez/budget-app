import Foundation
import Auth
import Supabase

// MARK: - AI Consent

enum AIConsent {
    static let key = "ai_insights_consent_granted"
    static var isGranted: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

// MARK: - Financial Snapshot

struct FinancialSnapshot: Sendable {
    let totalDebts: Int
    let totalAmountTracked: Decimal
    let totalPaidOff: Int
    let averageAmount: Decimal
    let totalPersons: Int
    let totalPayments: Int
    let totalPaymentAmount: Decimal
    let activeDebts: Int
    let overdueDebts: Int
    let owedToMeTotal: Decimal
    let iOweTotal: Decimal
    let netBalance: Decimal
    let categoryBreakdown: [String: Int]
    let topDebtorNames: [String]
    let currencyCode: String
    let tappedCardTitle: String
    let languageCode: String
}

// MARK: - Error

enum AIInsightsError: Error {
    case noAPIKey
    case networkError(Error)
    case invalidKey
    case rateLimited
    case httpError(Int)
    case decodingError
    case emptyResponse
    case consentRequired
    case notAuthenticated
    case proxyNotConfigured

    var displayMessage: String {
        let S = AppStrings.shared
        switch self {
        case .noAPIKey: return S.tr("ai.insights.error.title")
        case .invalidKey: return S.tr("ai.error.invalidKey")
        case .rateLimited: return S.tr("ai.error.rateLimited")
        case .networkError(let e): return e.localizedDescription
        case .httpError(let code): return S.tr("ai.error.serverError", "\(code)")
        case .decodingError, .emptyResponse: return S.tr("ai.insights.error.title")
        case .consentRequired: return S.tr("ai.insights.error.title")
        case .notAuthenticated: return S.tr("ai.insights.error.title")
        case .proxyNotConfigured: return S.tr("ai.insights.error.title")
        }
    }
}

// MARK: - Model Config
//
// The Anthropic API key now lives only on the server (Supabase Edge Function).
// The operator sets it once with:
//
//     supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
//
// and deploys the function with:
//
//     supabase functions deploy ai-insights
//
// The client only needs to know which model to ask for.

private enum AIModelConfig {
    static let shared: [String: String] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else { return [:] }
        return dict
    }()

    static var model: String { shared["ANTHROPIC_MODEL"] ?? "claude-sonnet-4-6" }
}

// MARK: - Protocol

protocol AIInsightsServiceProtocol: Sendable {
    func fetchInsight(for snapshot: FinancialSnapshot) async throws -> String
}

// MARK: - Anthropic Implementation (via Supabase Edge Function proxy)

final class AIInsightsService: AIInsightsServiceProtocol, Sendable {
    static let shared = AIInsightsService()

    private let anthropicVersion = "2023-06-01"
    private let maxTokens = 350

    /// URL of the deployed Supabase Edge Function that proxies Anthropic calls.
    /// The function name `ai-insights` must match `supabase/functions/ai-insights/`.
    private var proxyURL: URL? {
        let base = SupabaseConfig.projectURL
        guard !base.isEmpty else { return nil }
        return URL(string: "\(base)/functions/v1/ai-insights")
    }

    func fetchInsight(for snapshot: FinancialSnapshot) async throws -> String {
        // Opt-in gate: do not transmit any financial data to a third party
        // without explicit, granted consent.
        guard AIConsent.isGranted else {
            throw AIInsightsError.consentRequired
        }

        guard let endpoint = proxyURL else {
            throw AIInsightsError.proxyNotConfigured
        }

        // Require a Supabase session so the Edge Function's `verify_jwt`
        // gate has something to validate. Without this the gateway returns 401.
        let jwt: String
        do {
            let session = try await SupabaseAuthService.shared.client.auth.session
            jwt = session.accessToken
        } catch {
            throw AIInsightsError.notAuthenticated
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        // anthropic-version is forwarded by the proxy; sending it from the
        // client is harmless and lets the proxy stay version-agnostic if it
        // ever decides to honor the header.
        request.setValue(anthropicVersion, forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": AIModelConfig.model,
            "max_tokens": maxTokens,
            "messages": [
                ["role": "user", "content": buildPrompt(snapshot)]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIInsightsError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw AIInsightsError.networkError(URLError(.badServerResponse))
        }

        switch http.statusCode {
        case 200: break
        case 401: throw AIInsightsError.notAuthenticated
        case 429: throw AIInsightsError.rateLimited
        case 500:
            // The proxy returns 500 with {"error":"server misconfigured"} when
            // ANTHROPIC_API_KEY is not set on the function.
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               (json["error"] as? String) == "server misconfigured" {
                throw AIInsightsError.noAPIKey
            }
            throw AIInsightsError.httpError(500)
        default: throw AIInsightsError.httpError(http.statusCode)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String,
              !text.isEmpty
        else {
            throw AIInsightsError.decodingError
        }
        return text
    }

    private func buildPrompt(_ s: FinancialSnapshot) -> String {
        let languageInstruction: String
        switch s.languageCode {
        case "es": languageInstruction = "Respond in Spanish."
        case "fr": languageInstruction = "Respond in French."
        case "pt": languageInstruction = "Respond in Portuguese."
        case "ja": languageInstruction = "Respond in Japanese."
        case "ko": languageInstruction = "Respond in Korean."
        default: languageInstruction = "Respond in English."
        }

        let categoryList = s.categoryBreakdown
            .sorted { $0.value > $1.value }
            .prefix(4)
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")

        // Anonymize PII before third-party LLM call
        let anonymizedDebtors = s.topDebtorNames.enumerated().map { idx, _ in "Person \(idx + 1)" }
        let debtorList = anonymizedDebtors.isEmpty
            ? "none"
            : anonymizedDebtors.joined(separator: ", ")

        return """
        You are a concise personal finance advisor embedded in a debt-tracking iOS app. \
        \(languageInstruction)

        The user just tapped the "\(s.tappedCardTitle)" card on their dashboard. \
        Based on their full financial picture below, provide 2-3 sentences of \
        insightful, actionable advice specifically about what that card reveals. \
        Be warm, non-judgmental, and specific to their numbers. \
        Do NOT use markdown. Keep response under 80 words.

        Financial snapshot:
        - Total debts tracked: \(s.totalDebts) (\(s.activeDebts) active, \(s.overdueDebts) overdue)
        - Amount tracked: \(s.totalAmountTracked) \(s.currencyCode)
        - Owed to user: \(s.owedToMeTotal) \(s.currencyCode)
        - User owes: \(s.iOweTotal) \(s.currencyCode)
        - Net balance: \(s.netBalance) \(s.currencyCode)
        - Paid off: \(s.totalPaidOff) debts
        - Average debt: \(s.averageAmount) \(s.currencyCode)
        - Unique people: \(s.totalPersons)
        - Total payments recorded: \(s.totalPayments) (sum: \(s.totalPaymentAmount) \(s.currencyCode))
        - Top categories: \(categoryList)
        - Contacts with largest balances: \(debtorList)
        """
    }
}
