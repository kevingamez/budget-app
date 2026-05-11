import SwiftUI

private let S = AppStrings.shared

struct DebtDetailHeaderCard: View {
    let debt: Debt

    var body: some View {
        VStack(spacing: 16) {
            Text(debt.direction.label)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.colorForDirection(debt.direction))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(ColorTokens.colorForDirection(debt.direction).opacity(0.15), in: Capsule())

            Text(debt.totalAmount.currencyFormatted)
                .font(AppTypography.amountLarge)
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())

            Text(debt.title)
                .font(AppTypography.headline)
                .foregroundStyle(ColorTokens.textSecondary)

            if debt.derivedStatus != .forgiven {
                progressBlock
            }

            statusBadge
        }
        .cardStyle()
    }

    private var progressBlock: some View {
        VStack(spacing: 8) {
            AnimatedProgressBar(
                progress: debt.progressFraction,
                gradient: ColorTokens.gradientForDirection(debt.direction),
                height: 10
            )

            HStack {
                Text(S.tr("detail.paid", debt.paidAmount.currencyFormatted))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
                Spacer()
                Text(S.tr("detail.remaining", debt.remainingAmount.currencyFormatted))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
        }
    }

    private var statusBadge: some View {
        let status = debt.derivedStatus
        return Text(status.label)
            .font(AppTypography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor(for: status), in: Capsule())
    }

    private func statusColor(for status: DebtStatus) -> Color {
        switch status {
        case .active: ColorTokens.primaryAccent
        case .partiallyPaid: ColorTokens.gold
        case .paidOff: ColorTokens.green
        case .overdue: ColorTokens.overdueColor
        case .forgiven: ColorTokens.textTertiary
        }
    }
}
