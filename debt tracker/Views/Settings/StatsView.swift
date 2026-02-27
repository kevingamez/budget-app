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
                gradient: ColorTokens.primaryGradient
            )

            StatCard(
                icon: "dollarsign.circle.fill",
                title: S.tr("stats.amountTracked"),
                value: totalAmountTracked.compactFormatted,
                gradient: ColorTokens.goldGradient
            )

            StatCard(
                icon: "checkmark.seal.fill",
                title: S.tr("stats.paidOff"),
                value: "\(totalPaidOff)",
                gradient: ColorTokens.greenGradient
            )

            StatCard(
                icon: "chart.bar.fill",
                title: S.tr("stats.avgDebt"),
                value: averageAmount.compactFormatted,
                gradient: ColorTokens.redGradient
            )

            StatCard(
                icon: "person.2.fill",
                title: S.tr("stats.people"),
                value: "\(totalPersons)",
                gradient: ColorTokens.primaryGradient
            )

            StatCard(
                icon: "creditcard.fill",
                title: S.tr("stats.payments"),
                value: "\(totalPayments)",
                gradient: ColorTokens.greenGradient
            )
        }
    }
}

private struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(gradient)

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
}
