import SwiftUI

private let S = AppStrings.shared

/// Horizontal-scrolling cards modeled on Revolut's "Accounts" carousel —
/// each card represents one debt direction.
struct AccountCardsRow: View {
    let owedToMe: Decimal
    let iOwe: Decimal
    let activeCount: Int
    let overdueCount: Int

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize >= .accessibility1 {
            // Single-column stack lets cards grow vertically without crushing.
            VStack(spacing: 12) {
                owedCard.frame(maxWidth: .infinity, alignment: .leading)
                iOweCard.frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    owedCard
                    iOweCard
                }
                .padding(.horizontal, AppTheme.screenPadding)
            }
            // Counter the screenPadding parent — let cards bleed to the edge.
            .padding(.horizontal, -AppTheme.screenPadding)
        }
    }

    private var owedCard: some View {
        AccountCard(
            title: S.tr("balance.owedToMe"),
            amount: owedToMe,
            icon: "arrow.down.left",
            accentColor: ColorTokens.green,
            accentGradient: ColorTokens.greenGradient,
            detail: S.tr("dashboard.activeDebts") + " · \(activeCount)"
        )
    }

    private var iOweCard: some View {
        AccountCard(
            title: S.tr("balance.iOwe"),
            amount: iOwe,
            icon: "arrow.up.right",
            accentColor: ColorTokens.red,
            accentGradient: ColorTokens.redGradient,
            detail: overdueCount > 0
                ? S.tr("dashboard.overdue") + " · \(overdueCount)"
                : S.tr("dashboard.activeDebts") + " · \(activeCount)"
        )
    }
}

private struct AccountCard: View {
    let title: String
    let amount: Decimal
    let icon: String
    let accentColor: Color
    let accentGradient: LinearGradient
    let detail: String

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentGradient.opacity(0.18))
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accentColor)
                }
                .frame(width: 32, height: 32)

                Text(title)
                    .font(AppTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorTokens.textPrimary)
                    .lineLimit(typeSize >= .accessibility1 ? 2 : 1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }

            Text(amount.currencyFormatted)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(detail)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textTertiary)
                .lineLimit(typeSize >= .accessibility1 ? 2 : 1)
                .minimumScaleFactor(0.8)
        }
        .padding(16)
        .frame(
            maxWidth: typeSize >= .accessibility1 ? .infinity : nil,
            alignment: .leading
        )
        .frame(width: typeSize >= .accessibility1 ? nil : 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(ColorTokens.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .stroke(ColorTokens.surfaceBorder, lineWidth: 0.5)
                )
        )
    }
}
