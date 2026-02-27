import Foundation

@Observable
final class AIInsightsViewModel {
    var insightText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showNoAPIKeyPrompt: Bool = false

    private var cache: [String: CachedInsight] = [:]
    private let service: AIInsightsServiceProtocol

    init(service: AIInsightsServiceProtocol = AIInsightsService.shared) {
        self.service = service
    }

    func loadInsight(for snapshot: FinancialSnapshot) async {
        guard !isLoading else { return }

        guard KeychainService.loadAPIKey() != nil else {
            showNoAPIKeyPrompt = true
            return
        }

        let cacheKey = makeCacheKey(snapshot)
        if let cached = cache[cacheKey], cached.isValid {
            insightText = cached.text
            return
        }

        isLoading = true
        errorMessage = nil
        insightText = ""

        do {
            let text = try await service.fetchInsight(for: snapshot)
            insightText = text
            cache[cacheKey] = CachedInsight(text: text)
        } catch let error as AIInsightsError {
            if case .noAPIKey = error {
                showNoAPIKeyPrompt = true
            } else {
                errorMessage = error.displayMessage
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func clearCache() {
        cache = [:]
    }

    private func makeCacheKey(_ s: FinancialSnapshot) -> String {
        "\(s.tappedCardTitle)|\(s.totalDebts)|\(s.totalAmountTracked)|\(s.totalPaidOff)|\(s.totalPayments)|\(s.totalPersons)"
    }
}

private struct CachedInsight {
    let text: String
    let timestamp: Date = Date()

    var isValid: Bool {
        Date().timeIntervalSince(timestamp) < 3600
    }
}
