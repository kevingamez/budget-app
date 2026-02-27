import SwiftUI

private let S = AppStrings.shared

struct DebtProgressCard: View {
    let debts: [Debt]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ColorTokens.primaryAccent)
                Text(S.tr("progress.almostPaidOff"))
                    .font(AppTypography.headline)
                    .foregroundStyle(ColorTokens.textPrimary)
                Spacer()
            }

            if debts.isEmpty {
                Text(S.tr("progress.empty"))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
            } else {
                ForEach(debts) { debt in
                    VStack(spacing: 8) {
                        HStack {
                            Text(debt.personName)
                                .font(AppTypography.subheadline)
                                .foregroundStyle(ColorTokens.textPrimary)

                            Spacer()

                            Text(debt.remainingAmount.currencyFormatted)
                                .font(AppTypography.footnote)
                                .foregroundStyle(ColorTokens.textSecondary)
                        }

                        AnimatedProgressBar(
                            progress: debt.progressFraction,
                            gradient: ColorTokens.gradientForDirection(debt.direction),
                            height: 6
                        )
                    }

                    if debt.id != debts.last?.id {
                        Divider()
                            .background(ColorTokens.surfaceBorder)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
