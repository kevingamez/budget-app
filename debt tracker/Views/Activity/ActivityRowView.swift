import SwiftUI

private let S = AppStrings.shared

struct ActivityRowView: View {
    let payment: Payment
    let isLast: Bool

    private var direction: DebtDirection {
        payment.debt?.direction ?? .owedToMe
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline
            VStack(spacing: 0) {
                Circle()
                    .fill(ColorTokens.colorForDirection(direction))
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)

                if !isLast {
                    Rectangle()
                        .fill(ColorTokens.surfaceBorder)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 10)

            // Content
            HStack(spacing: 12) {
                PersonAvatarView(person: payment.debt?.person, size: .small)

                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.debt?.personName ?? S.tr("common.unknown"))
                        .font(AppTypography.headline)
                        .foregroundStyle(ColorTokens.textPrimary)

                    Text(payment.debt?.title ?? "")
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                        .lineLimit(1)

                    if let notes = payment.notes {
                        Text(notes)
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textTertiary)
                            .italic()
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(payment.amount.currencyFormatted)
                        .font(AppTypography.amountSmall)
                        .foregroundStyle(ColorTokens.colorForDirection(direction))

                    Text(payment.date.relativeFormatted)
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
