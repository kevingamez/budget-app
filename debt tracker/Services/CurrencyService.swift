import Foundation

struct ExchangeRateResponse: Codable {
    let result: String
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case result
        case rates = "conversion_rates"
    }
}

@Observable
final class CurrencyService {
    static let shared = CurrencyService()

    var rates: [String: Double] = [:]
    var lastFetched: Date?
    var isLoading = false
    var errorMessage: String?

    // Free API — no key needed, 1500 requests/month
    private let baseURL = "https://open.er-api.com/v6/latest/USD"

    /// Sanity bounds. Any rate outside this range is rejected to defend against
    /// a poisoned/malformed upstream that would otherwise propagate NaN/Infinity
    /// into `Decimal` and crash, or silently corrupt amounts shown to the user.
    private static let minValidRate: Double = 1e-6
    private static let maxValidRate: Double = 1e6

    func fetchRates() async {
        guard !isLoading else { return }

        // Cache for 1 hour
        if let lastFetched, Date().timeIntervalSince(lastFetched) < 3600, !rates.isEmpty {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            guard let url = URL(string: baseURL) else { return }
            let (data, urlResponse) = try await URLSession.shared.data(from: url)

            guard let http = urlResponse as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }

            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            guard response.result == "success" else {
                throw URLError(.cannotParseResponse)
            }

            rates = Self.sanitize(rates: response.rates)
            guard !rates.isEmpty else {
                throw URLError(.cannotParseResponse)
            }
            lastFetched = Date()
        } catch {
            errorMessage = "Could not fetch exchange rates"
        }

        isLoading = false
    }

    /// Drop entries that are NaN, infinite, non-positive, or absurdly large.
    private static func sanitize(rates: [String: Double]) -> [String: Double] {
        rates.filter { _, value in
            value.isFinite && value >= minValidRate && value <= maxValidRate
        }
    }

    func convert(amount: Decimal, from: String, to: String) -> Decimal? {
        guard let fromRate = rates[from], let toRate = rates[to],
              fromRate > 0, toRate > 0 else {
            return nil
        }
        let amountDouble = NSDecimalNumber(decimal: amount).doubleValue
        let converted = (amountDouble / fromRate) * toRate
        guard converted.isFinite else { return nil }
        return Decimal(converted)
    }

    func rate(from: String, to: String) -> Double? {
        guard let fromRate = rates[from], let toRate = rates[to],
              fromRate > 0, toRate > 0 else {
            return nil
        }
        let r = toRate / fromRate
        return r.isFinite ? r : nil
    }
}
