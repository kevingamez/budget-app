import SwiftUI

private let S = AppStrings.shared

// MARK: - Hero Balance
//
// Revolut's signature: a giant number in a thin weight on flat background,
// with the whole-units bold and the cents lighter to soften visual weight.

struct RevolutHeroBalance: View {
    let netBalance: Decimal
    let owedToMe: Decimal
    let iOwe: Decimal

    private var sign: String { netBalance < 0 ? "-" : "" }
    private var absoluteString: String { abs(netBalance).currencyFormatted }

    /// Splits a formatted currency like "$1,234.56" into ("$1,234", ".56").
    private var split: (whole: String, fraction: String) {
        let str = absoluteString
        if let dotIdx = str.lastIndex(of: ".") {
            return (String(str[..<dotIdx]), String(str[dotIdx...]))
        }
        if let commaIdx = str.lastIndex(of: ",") {
            // For locales using comma as decimal separator
            return (String(str[..<commaIdx]), String(str[commaIdx...]))
        }
        return (str, "")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            Text(S.tr("balance.netBalance").uppercased())
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(ColorTokens.textTertiary)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                if !sign.isEmpty {
                    Text(sign)
                        .font(.system(.largeTitle, design: .rounded).weight(.light))
                        .foregroundStyle(ColorTokens.textPrimary)
                }
                Text(split.whole)
                    .font(.system(.largeTitle, design: .rounded).weight(.light))
                    .foregroundStyle(ColorTokens.textPrimary)
                Text(split.fraction)
                    .font(.system(.largeTitle, design: .rounded).weight(.light))
                    .foregroundStyle(ColorTokens.textSecondary)
                    .baselineOffset(0)
            }
            .contentTransition(.numericText())
            .lineLimit(1)
            .minimumScaleFactor(0.6)

            HStack(spacing: 8) {
                BalanceChip(
                    icon: "arrow.down.left",
                    label: S.tr("balance.owedToMe"),
                    amount: owedToMe,
                    tint: ColorTokens.green
                )
                BalanceChip(
                    icon: "arrow.up.right",
                    label: S.tr("balance.iOwe"),
                    amount: iOwe,
                    tint: ColorTokens.red
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

private struct BalanceChip: View {
    let icon: String
    let label: String
    let amount: Decimal
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
            Text(amount.currencyFormatted)
                .font(AppTypography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ColorTokens.surface, in: Capsule())
        .overlay(Capsule().stroke(ColorTokens.surfaceBorder, lineWidth: 0.5))
    }
}

// MARK: - Quick Actions
//
// Circular tinted icon-buttons with labels — Revolut's "Add money / Transfer / Pay"
// row sits directly under the hero balance.

struct QuickAction: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let action: () -> Void
}

struct QuickActionsRow: View {
    let actions: [QuickAction]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(actions) { action in
                Button(action: action.action) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(ColorTokens.surface)
                                .overlay(Circle().stroke(ColorTokens.surfaceBorder, lineWidth: 0.5))
                            Image(systemName: action.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(ColorTokens.primaryAccent)
                        }
                        .frame(width: 52, height: 52)

                        Text(action.label)
                            .font(.system(.caption, design: .rounded).weight(.medium))
                            .foregroundStyle(ColorTokens.textPrimary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .pressable()
                #if os(iOS)
                .hoverEffect(.lift)
                #endif
            }
        }
    }
}

// MARK: - Account Cards Row
//
// Horizontal-scrolling cards modeled on Revolut's "Accounts" carousel —
// each card represents one debt direction, with a mini progress bar.

struct AccountCardsRow: View {
    let owedToMe: Decimal
    let iOwe: Decimal
    let activeCount: Int
    let overdueCount: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                AccountCard(
                    title: S.tr("balance.owedToMe"),
                    amount: owedToMe,
                    icon: "arrow.down.left",
                    accentColor: ColorTokens.green,
                    accentGradient: ColorTokens.greenGradient,
                    detail: S.tr("dashboard.activeDebts") + " · \(activeCount)"
                )
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
            .padding(.horizontal, AppTheme.screenPadding)
        }
        // Counter the screenPadding parent — let cards bleed to the edge.
        .padding(.horizontal, -AppTheme.screenPadding)
    }
}

private struct AccountCard: View {
    let title: String
    let amount: Decimal
    let icon: String
    let accentColor: Color
    let accentGradient: LinearGradient
    let detail: String

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
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            Text(amount.currencyFormatted)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(detail)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(16)
        .frame(width: 220, alignment: .leading)
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

// MARK: - Transactions List
//
// Flat, dense list with circular avatars, no surrounding card chrome —
// like Revolut's transactions feed.

struct TransactionsListSection: View {
    let payments: [Payment]
    let onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(S.tr("recent.title"))
                    .font(AppTypography.headline)
                    .foregroundStyle(ColorTokens.textPrimary)
                Spacer()
                Button(action: onSeeAll) {
                    HStack(spacing: 2) {
                        Text(S.tr("dashboard.seeAll"))
                            .font(AppTypography.footnote)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(ColorTokens.primaryAccent)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)

            if payments.isEmpty {
                Text(S.tr("recent.empty"))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(payments) { payment in
                        TransactionRow(payment: payment)
                            .padding(.vertical, 10)

                        if payment.id != payments.last?.id {
                            Rectangle()
                                .fill(ColorTokens.surfaceBorder)
                                .frame(height: 0.5)
                                .padding(.leading, 52)
                        }
                    }
                }
            }
        }
    }
}

private struct TransactionRow: View {
    let payment: Payment

    private var amountTint: Color {
        guard let direction = payment.debt?.direction else { return ColorTokens.textPrimary }
        return direction == .owedToMe ? ColorTokens.green : ColorTokens.red
    }

    private var amountPrefix: String {
        guard let direction = payment.debt?.direction else { return "" }
        return direction == .owedToMe ? "+" : "-"
    }

    var body: some View {
        HStack(spacing: 12) {
            PersonAvatarView(person: payment.debt?.person, size: .small)

            VStack(alignment: .leading, spacing: 2) {
                Text(payment.debt?.personName ?? S.tr("common.unknown"))
                    .font(AppTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(ColorTokens.textPrimary)
                    .lineLimit(1)

                Text(payment.debt?.title ?? S.tr("common.unknown"))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(amountPrefix)\(payment.amount.currencyFormatted)")
                    .font(AppTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(amountTint)

                Text(payment.date.relativeFormatted)
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
            }
        }
    }
}

// MARK: - Insight Tiles
//
// Compact two-up tile row — the small surface for headline numbers
// (active debts, overdue) that Revolut uses for "Analytics" preview cards.

struct InsightTilesRow: View {
    let activeCount: Int
    let overdueCount: Int
    let almostPaidCount: Int

    var body: some View {
        HStack(spacing: 12) {
            InsightTile(
                value: "\(activeCount)",
                label: S.tr("dashboard.activeDebts"),
                icon: "doc.text.fill",
                tint: ColorTokens.primaryAccent
            )
            InsightTile(
                value: "\(overdueCount)",
                label: S.tr("dashboard.overdue"),
                icon: "exclamationmark.triangle.fill",
                tint: overdueCount > 0 ? ColorTokens.red : ColorTokens.green
            )
            InsightTile(
                value: "\(almostPaidCount)",
                label: S.tr("dashboard.almostPaid"),
                icon: "checkmark.seal.fill",
                tint: ColorTokens.gold
            )
        }
    }
}

private struct InsightTile: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
            }
            .frame(width: 28, height: 28)

            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(.caption2, design: .rounded).weight(.medium))
                .foregroundStyle(ColorTokens.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorTokens.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTokens.surfaceBorder, lineWidth: 0.5)
                )
        )
    }
}
