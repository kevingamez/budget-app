import Foundation

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

    var displayMessage: String {
        let S = AppStrings.shared
        switch self {
        case .noAPIKey: return S.tr("ai.insights.noKey.title")
        case .invalidKey: return S.tr("ai.error.invalidKey")
        case .rateLimited: return S.tr("ai.error.rateLimited")
        case .networkError(let e): return e.localizedDescription
        case .httpError(let code): return S.tr("ai.error.serverError", "\(code)")
        case .decodingError, .emptyResponse: return S.tr("ai.insights.error.title")
        }
    }
}

// MARK: - Protocol

protocol AIInsightsServiceProtocol: Sendable {
    func fetchInsight(for snapshot: FinancialSnapshot) async throws -> String
}

// MARK: - Anthropic Implementation

final class AIInsightsService: AIInsightsServiceProtocol, Sendable {
    static let shared = AIInsightsService()

    private let model = "claude-haiku-4-5-20251001"
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let anthropicVersion = "2023-06-01"
    private let maxTokens = 350

    func fetchInsight(for snapshot: FinancialSnapshot) async throws -> String {
        guard let apiKey = KeychainService.loadAPIKey(), !apiKey.isEmpty else {
            throw AIInsightsError.noAPIKey
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(anthropicVersion, forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
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
        case 401: throw AIInsightsError.invalidKey
        case 429: throw AIInsightsError.rateLimited
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

        let debtorList = s.topDebtorNames.isEmpty
            ? "none"
            : s.topDebtorNames.joined(separator: ", ")

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
