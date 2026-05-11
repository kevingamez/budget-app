import SwiftUI

private let S = AppStrings.shared

struct DebtRowView: View {
    let debt: Debt

    @Environment(\.dynamicTypeSize) private var typeSize

    /// Cached per-render snapshot so `payments`-walking computed properties
    /// (`derivedStatus`, `progressFraction`, `isOverdue`, `remainingAmount`)
    /// are evaluated once per body instead of 4+ times.
    private struct RowDisplay {
        let status: DebtStatus
        let progress: Double
        let isOverdue: Bool
        let remaining: Decimal
    }

    private var display: RowDisplay {
        RowDisplay(
            status: debt.derivedStatus,
            progress: debt.progressFraction,
            isOverdue: debt.isOverdue,
            remaining: debt.remainingAmount
        )
    }

    var body: some View {
        let d = display
        adaptiveContainer {
            // Avatar
            PersonAvatarView(person: debt.person, size: .medium)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(debt.personName)
                        .font(AppTypography.headline)
                        .foregroundStyle(ColorTokens.textPrimary)

                    if d.status == .overdue {
                        Text(S.tr("status.overdueBadge"))
                            .font(AppTypography.caption2.weight(.bold))
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
                            .font(AppTypography.caption2)
                        Text(category.name)
                            .font(AppTypography.caption)
                    }
                    .foregroundStyle(Color(hex: category.colorHex))
                }
            }

            if typeSize < .accessibility1 {
                Spacer()
            }

            // Amount + Progress
            VStack(alignment: typeSize >= .accessibility1 ? .leading : .trailing, spacing: 4) {
                Text(debt.totalAmount.currencyFormatted)
                    .font(AppTypography.amountSmall)
                    .foregroundStyle(ColorTokens.colorForDirection(debt.direction))
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if d.progress > 0 && d.status != .paidOff {
                    AnimatedProgressBar(
                        progress: d.progress,
                        gradient: ColorTokens.gradientForDirection(debt.direction),
                        height: 4
                    )
                    .frame(width: 60)
                } else if d.status == .paidOff {
                    Text(S.tr("status.paid"))
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.green)
                } else if d.status == .forgiven {
                    Text(S.tr("status.forgiven"))
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.gold)
                }

                if let dueDate = debt.dueDate, d.status != .paidOff, d.status != .forgiven {
                    Text(dueDate.relativeFormatted)
                        .font(AppTypography.caption)
                        .foregroundStyle(d.isOverdue ? ColorTokens.overdueColor : ColorTokens.textTertiary)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(ColorTokens.surface)
                .shadow(color: AppTheme.cardShadow, radius: 6, y: 3)
        )
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        #if os(iOS)
        .hoverEffect(.lift)
        #endif
        .accessibilityElement(children: .combine)
        .accessibilityLabel(S.tr("a11y.debt.row", debt.personName, debt.totalAmount.currencyFormatted, d.status.label))
        .accessibilityHint(S.tr("a11y.debt.row.hint"))
    }

    /// Horizontal layout normally; vertical (avatar + info + amount stacked) at
    /// accessibility sizes so the amount column doesn't crush the name.
    @ViewBuilder
    private func adaptiveContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if typeSize >= .accessibility1 {
            VStack(alignment: .leading, spacing: 12) { content() }
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(spacing: 14) { content() }
        }
    }
}
