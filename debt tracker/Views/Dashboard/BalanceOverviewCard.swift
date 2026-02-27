import SwiftUI

private let S = AppStrings.shared

struct BalanceOverviewCard: View {
    let totalOwedToMe: Decimal
    let totalIOwe: Decimal
    let netBalance: Decimal

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            // Net Balance
            VStack(spacing: 4) {
                Text(S.tr("balance.netBalance"))
                    .font(AppTypography.footnote)
                    .foregroundStyle(.white.opacity(0.7))

                Text(netBalance.currencyFormatted)
                    .font(AppTypography.amountLarge)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            // Owed To Me vs I Owe
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text(S.tr("balance.owedToMe"))
                            .font(AppTypography.caption)
                    }
                    .foregroundStyle(.white.opacity(0.7))

                    Text(totalOwedToMe.currencyFormatted)
                        .font(AppTypography.amountSmall)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }

                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 40)

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .semibold))
                        Text(S.tr("balance.iOwe"))
                            .font(AppTypography.caption)
                    }
                    .foregroundStyle(.white.opacity(0.7))

                    Text(totalIOwe.currencyFormatted)
                        .font(AppTypography.amountSmall)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
            }

            // Balance Bar
            GeometryReader { geo in
                let total = NSDecimalNumber(decimal: totalOwedToMe + totalIOwe).doubleValue
                let ratio = total > 0
                    ? NSDecimalNumber(decimal: totalOwedToMe).doubleValue / total
                    : 0.5

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.15))

                    Capsule()
                        .fill(.white.opacity(0.5))
                        .frame(width: appeared ? geo.size.width * ratio : 0)
                        .animation(AppAnimations.progressFill, value: appeared)
                }
            }
            .frame(height: 6)
        }
        .padding(AppTheme.cardPadding + 4)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(ColorTokens.primaryGradient)
                .shadow(color: ColorTokens.primaryAccent.opacity(0.3), radius: 16, y: 8)
        )
        .onAppear {
            appeared = true
        }
    }
}
