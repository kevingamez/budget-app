import SwiftUI

private let S = AppStrings.shared

struct PaymentHistorySection: View {
    let payments: [Payment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(S.tr("detail.paymentHistory"))
                .font(AppTypography.headline)
                .foregroundStyle(ColorTokens.textPrimary)

            if payments.isEmpty {
                Text(S.tr("detail.noPayments"))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(payments) { payment in
                    PaymentRow(payment: payment)
                }
            }
        }
        .cardStyle()
    }
}

private struct PaymentRow: View {
    let payment: Payment

    var body: some View {
        HStack {
            Circle()
                .fill(ColorTokens.green)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(payment.amount.currencyFormatted)
                    .font(AppTypography.headline)
                    .foregroundStyle(ColorTokens.textPrimary)
                if let notes = payment.notes {
                    Text(notes)
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
            }

            Spacer()

            Text(payment.date.relativeFormatted)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .padding(.vertical, 6)
    }
}
