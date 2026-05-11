import SwiftUI

private let S = AppStrings.shared

/// Flat, dense list with circular avatars, no surrounding card chrome —
/// like Revolut's transactions feed.
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
