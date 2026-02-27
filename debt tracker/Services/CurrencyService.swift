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
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            rates = response.rates
            lastFetched = Date()
        } catch {
            errorMessage = "Could not fetch exchange rates"
        }

        isLoading = false
    }

    func convert(amount: Decimal, from: String, to: String) -> Decimal? {
        guard let fromRate = rates[from], let toRate = rates[to], fromRate > 0 else {
            return nil
        }
        let usdAmount = NSDecimalNumber(decimal: amount).doubleValue / fromRate
        let converted = usdAmount * toRate
        return Decimal(converted)
    }

    func rate(from: String, to: String) -> Double? {
        guard let fromRate = rates[from], let toRate = rates[to], fromRate > 0 else {
            return nil
        }
        return toRate / fromRate
    }
}
