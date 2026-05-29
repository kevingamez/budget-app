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
    /// PII: top debtors are never sent to the server. Only the count is
    /// forwarded so the prompt can render anonymized placeholders.
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
    case dailyLimitReached

    @MainActor
    var displayMessage: String {
        let S = AppStrings.shared
        switch self {
        case .noAPIKey: return S.tr("ai.insights.error.title")
        case .invalidKey: return S.tr("ai.error.invalidKey")
        case .rateLimited, .dailyLimitReached: return S.tr("ai.error.rateLimited")
        case .networkError: return S.tr("ai.error.network")
        case .httpError(let code): return S.tr("ai.error.serverError", "\(code)")
        case .decodingError, .emptyResponse: return S.tr("ai.insights.error.title")
        case .consentRequired: return S.tr("ai.insights.error.title")
        case .notAuthenticated: return S.tr("ai.insights.error.title")
        case .proxyNotConfigured: return S.tr("ai.insights.error.title")
        }
    }
}

/// Per-day client-side rate limiter for AI insight calls. The Edge Function
/// already enforces JWT, but throttling on the client prevents accidental loops
/// (held buttons, retry storms) from racking up Anthropic costs.
///
/// **Defense-in-depth only.** A modified client can bypass this; the Edge
/// Function should ALSO throttle keyed on `auth.uid()` (TODO server-side).
enum AIInsightRateLimit {
    static let dailyCap = 10
    private static let countKey = "ai_insights_daily_count"
    private static let dayKey = "ai_insights_daily_day"

    private static func today() -> String {
        ISO8601DateFormatter.string(from: Date(), timeZone: .current,
                                    formatOptions: [.withFullDate])
    }

    /// Today's consumed count (a stale day reads as 0 without mutating storage).
    private static func currentCount() -> Int {
        guard UserDefaults.standard.string(forKey: dayKey) == today() else { return 0 }
        return UserDefaults.standard.integer(forKey: countKey)
    }

    /// Peek: may another call proceed? Does NOT increment, so failed/retried
    /// requests don't burn the user's daily quota.
    static func canProceed() -> Bool {
        currentCount() < dailyCap
    }

    /// Commit one *successful* call against today's quota. Call this only after
    /// a real insight is returned — never on a network/decoding failure.
    static func recordSuccess() {
        let today = today()
        let lastDay = UserDefaults.standard.string(forKey: dayKey)
        var count = UserDefaults.standard.integer(forKey: countKey)
        if lastDay != today {
            count = 0
            UserDefaults.standard.set(today, forKey: dayKey)
        }
        UserDefaults.standard.set(count + 1, forKey: countKey)
    }
}

// MARK: - Protocol

protocol AIInsightsServiceProtocol: Sendable {
    func fetchInsight(for snapshot: FinancialSnapshot) async throws -> String
}

// MARK: - Anthropic Implementation (via Supabase Edge Function proxy)
//
// The Anthropic API key, model, max_tokens, system prompt, and message
// structure all live on the server (Supabase Edge Function) — see
// supabase/functions/ai-insights/index.ts. The client only POSTs a typed
// financial snapshot and a consent flag; any attempt to send extra fields is
// rejected by the proxy. This shape prevents a modified client from choosing
// a more expensive model, injecting an arbitrary prompt, or smuggling
// Anthropic tool definitions through the proxy.

final class AIInsightsService: AIInsightsServiceProtocol, Sendable {
    static let shared = AIInsightsService()

    /// URL of the deployed Supabase Edge Function that proxies Anthropic calls.
    /// The function name `ai-insights` must match `supabase/functions/ai-insights/`.
    private var proxyURL: URL? {
        let base = SupabaseConfig.projectURL
        guard !base.isEmpty else { return nil }
        return URL(string: "\(base)/functions/v1/ai-insights")
    }

    func fetchInsight(for snapshot: FinancialSnapshot) async throws -> String {
        // Opt-in gate: do not transmit any financial data to a third party
        // without explicit, granted consent. The server also enforces this —
        // this client-side check just avoids a wasted network round-trip.
        guard AIConsent.isGranted else {
            throw AIInsightsError.consentRequired
        }

        // Defense-in-depth: throttle locally so a stuck UI loop or held button
        // can't burn cost. The server enforces the real per-user cap via a
        // Postgres counter (see migrations/*_ai_usage.sql). We only *peek* here
        // and commit a slot after a successful response — otherwise a string of
        // network/decoding failures (one tap away via Retry/Regenerate) would
        // exhaust the daily quota without ever producing an insight.
        guard AIInsightRateLimit.canProceed() else {
            throw AIInsightsError.dailyLimitReached
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

        // The proxy schema only accepts {consent, snapshot}. Anything else
        // (model, max_tokens, messages, …) is a hard 400.
        let body: [String: Any] = [
            "consent": true,
            "snapshot": Self.encode(snapshot),
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
        // Success — only now commit a slot against the daily quota.
        AIInsightRateLimit.recordSuccess()
        return text
    }

    /// Build the JSON payload the proxy accepts. Names are anonymized to a
    /// count so the third-party LLM never sees PII even on the server.
    private static func encode(_ s: FinancialSnapshot) -> [String: Any] {
        return [
            "totalDebts": s.totalDebts,
            "activeDebts": s.activeDebts,
            "overdueDebts": s.overdueDebts,
            "totalAmountTracked": decimalToDouble(s.totalAmountTracked),
            "owedToMeTotal": decimalToDouble(s.owedToMeTotal),
            "iOweTotal": decimalToDouble(s.iOweTotal),
            "netBalance": decimalToDouble(s.netBalance),
            "totalPaidOff": s.totalPaidOff,
            "averageAmount": decimalToDouble(s.averageAmount),
            "totalPersons": s.totalPersons,
            "totalPayments": s.totalPayments,
            "totalPaymentAmount": decimalToDouble(s.totalPaymentAmount),
            "topDebtorCount": s.topDebtorNames.count,
            "categoryBreakdown": s.categoryBreakdown,
            "currencyCode": s.currencyCode,
            "tappedCardTitle": s.tappedCardTitle,
            "languageCode": s.languageCode,
        ]
    }

    private static func decimalToDouble(_ d: Decimal) -> Double {
        let v = NSDecimalNumber(decimal: d).doubleValue
        return v.isFinite ? v : 0
    }
}
