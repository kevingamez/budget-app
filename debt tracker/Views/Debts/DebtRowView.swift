import SwiftUI

private let S = AppStrings.shared

struct DebtRowView: View {
    let debt: Debt

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            PersonAvatarView(person: debt.person, size: .medium)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(debt.personName)
                        .font(AppTypography.headline)
                        .foregroundStyle(ColorTokens.textPrimary)

                    if debt.derivedStatus == .overdue {
                        Text(S.tr("status.overdueBadge"))
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(ColorTokens.overdueColor, in: Capsule())
                    }
                }

                Text(debt.title)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textSecondary)
                    .lineLimit(1)

                if let category = debt.category {
                    HStack(spacing: 4) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 10))
                        Text(category.name)
                            .font(AppTypography.caption)
                    }
                    .foregroundStyle(Color(hex: category.colorHex))
                }
            }

            Spacer()

            // Amount + Progress
            VStack(alignment: .trailing, spacing: 4) {
                Text(debt.totalAmount.currencyFormatted)
                    .font(AppTypography.amountSmall)
                    .foregroundStyle(ColorTokens.colorForDirection(debt.direction))
                    .contentTransition(.numericText())

                if debt.progressFraction > 0 && debt.derivedStatus != .paidOff {
                    AnimatedProgressBar(
                        progress: debt.progressFraction,
                        gradient: ColorTokens.gradientForDirection(debt.direction),
                        height: 4
                    )
                    .frame(width: 60)
                } else if debt.derivedStatus == .paidOff {
                    Text(S.tr("status.paid"))
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.green)
                } else if debt.derivedStatus == .forgiven {
                    Text(S.tr("status.forgiven"))
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.gold)
                }

                if let dueDate = debt.dueDate, debt.derivedStatus != .paidOff, debt.derivedStatus != .forgiven {
                    Text(dueDate.relativeFormatted)
                        .font(AppTypography.caption)
                        .foregroundStyle(debt.isOverdue ? ColorTokens.overdueColor : ColorTokens.textTertiary)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(ColorTokens.surface)
                .shadow(color: AppTheme.cardShadow, radius: 6, y: 3)
        )
    }
}
