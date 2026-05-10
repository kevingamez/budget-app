import Foundation

@Observable
final class AIInsightsViewModel {
    var insightText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private var cache: [String: CachedInsight] = [:]
    private let service: AIInsightsServiceProtocol

    init(service: AIInsightsServiceProtocol = AIInsightsService.shared) {
        self.service = service
    }

    func loadInsight(for snapshot: FinancialSnapshot) async {
        guard !isLoading else { return }

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
            errorMessage = error.displayMessage
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

    /// Aggregates a FinancialSnapshot for the given debts/persons/payments.
    /// Keeps all aggregation + UserDefaults reads out of the view layer.
    func buildSnapshot(
        tappedTitle: String,
        debts: [Debt],
        persons: [Person],
        payments: [Payment]
    ) -> FinancialSnapshot {
        let totalDebts = debts.count
        let totalAmountTracked = debts.reduce(Decimal.zero) { $0 + $1.totalAmount }
        let totalPaidOff = debts.filter { $0.derivedStatus == .paidOff || $0.derivedStatus == .forgiven }.count
        let averageAmount = debts.isEmpty ? Decimal.zero : totalAmountTracked / Decimal(debts.count)

        let owedToMe = debts
            .filter { $0.direction == .owedToMe }
            .reduce(Decimal.zero) { $0 + $1.remainingAmount }
        let iOwe = debts
            .filter { $0.direction == .iOwe }
            .reduce(Decimal.zero) { $0 + $1.remainingAmount }

        var categoryBreakdown: [String: Int] = [:]
        for debt in debts {
            let name = debt.category?.categoryType.rawValue ?? "other"
            categoryBreakdown[name, default: 0] += 1
        }

        let topDebtors = debts
            .sorted { $0.remainingAmount > $1.remainingAmount }
            .prefix(3)
            .compactMap { $0.person?.name }

        let totalPaymentAmount = payments.reduce(Decimal.zero) { $0 + $1.amount }

        return FinancialSnapshot(
            totalDebts: totalDebts,
            totalAmountTracked: totalAmountTracked,
            totalPaidOff: totalPaidOff,
            averageAmount: averageAmount,
            totalPersons: persons.count,
            totalPayments: payments.count,
            totalPaymentAmount: totalPaymentAmount,
            activeDebts: debts.filter { $0.derivedStatus == .active || $0.derivedStatus == .partiallyPaid }.count,
            overdueDebts: debts.filter { $0.isOverdue }.count,
            owedToMeTotal: owedToMe,
            iOweTotal: iOwe,
            netBalance: owedToMe - iOwe,
            categoryBreakdown: categoryBreakdown,
            topDebtorNames: topDebtors,
            currencyCode: UserDefaults.standard.string(forKey: "currencyCode") ?? "USD",
            tappedCardTitle: tappedTitle,
            languageCode: AppStrings.shared.language
        )
    }
}

private struct CachedInsight {
    let text: String
    let timestamp: Date = Date()

    var isValid: Bool {
        Date().timeIntervalSince(timestamp) < 3600
    }
}
