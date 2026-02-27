import SwiftUI

private let S = AppStrings.shared

struct StatsView: View {
    let totalDebts: Int
    let totalAmountTracked: Decimal
    let totalPaidOff: Int
    let averageAmount: Decimal
    let totalPersons: Int
    let totalPayments: Int
    let totalPaymentAmount: Decimal
    var debts: [Debt] = []
    var persons: [Person] = []
    var onCardTapped: ((FinancialSnapshot, LinearGradient) -> Void)?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatCard(
                icon: "doc.text.fill",
                title: S.tr("stats.totalDebts"),
                value: "\(totalDebts)",
                gradient: ColorTokens.primaryGradient,
                onTap: { onCardTapped?(buildSnapshot(S.tr("stats.totalDebts")), ColorTokens.primaryGradient) }
            )

            StatCard(
                icon: "dollarsign.circle.fill",
                title: S.tr("stats.amountTracked"),
                value: totalAmountTracked.compactFormatted,
                gradient: ColorTokens.goldGradient,
                onTap: { onCardTapped?(buildSnapshot(S.tr("stats.amountTracked")), ColorTokens.goldGradient) }
            )

            StatCard(
                icon: "checkmark.seal.fill",
                title: S.tr("stats.paidOff"),
                value: "\(totalPaidOff)",
                gradient: ColorTokens.greenGradient,
                onTap: { onCardTapped?(buildSnapshot(S.tr("stats.paidOff")), ColorTokens.greenGradient) }
            )

            StatCard(
                icon: "chart.bar.fill",
                title: S.tr("stats.avgDebt"),
                value: averageAmount.compactFormatted,
                gradient: ColorTokens.redGradient,
                onTap: { onCardTapped?(buildSnapshot(S.tr("stats.avgDebt")), ColorTokens.redGradient) }
            )

            StatCard(
                icon: "person.2.fill",
                title: S.tr("stats.people"),
                value: "\(totalPersons)",
                gradient: ColorTokens.primaryGradient,
                onTap: { onCardTapped?(buildSnapshot(S.tr("stats.people")), ColorTokens.primaryGradient) }
            )

            StatCard(
                icon: "creditcard.fill",
                title: S.tr("stats.payments"),
                value: "\(totalPayments)",
                gradient: ColorTokens.greenGradient,
                onTap: { onCardTapped?(buildSnapshot(S.tr("stats.payments")), ColorTokens.greenGradient) }
            )
        }
    }

    private func buildSnapshot(_ tappedTitle: String) -> FinancialSnapshot {
        let owedToMe = debts.filter { $0.direction == .owedToMe }.reduce(Decimal.zero) { $0 + $1.remainingAmount }
        let iOwe = debts.filter { $0.direction == .iOwe }.reduce(Decimal.zero) { $0 + $1.remainingAmount }

        var categoryBreakdown: [String: Int] = [:]
        for debt in debts {
            let name = debt.category?.categoryType.rawValue ?? "other"
            categoryBreakdown[name, default: 0] += 1
        }

        let topDebtors = debts
            .sorted { $0.remainingAmount > $1.remainingAmount }
            .prefix(3)
            .compactMap { $0.person?.name }

        return FinancialSnapshot(
            totalDebts: totalDebts,
            totalAmountTracked: totalAmountTracked,
            totalPaidOff: totalPaidOff,
            averageAmount: averageAmount,
            totalPersons: totalPersons,
            totalPayments: totalPayments,
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

private struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let gradient: LinearGradient
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(gradient)
                    Spacer()
                    if onTap != nil {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(ColorTokens.textTertiary)
                    }
                }

                Text(value)
                    .font(AppTypography.title2)
                    .foregroundStyle(ColorTokens.textPrimary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
        .buttonStyle(.plain)
        .pressable()
    }
}
